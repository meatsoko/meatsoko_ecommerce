<?php

namespace App\Http\Controllers\Payment_Methods;

use App\Models\PaymentRequest;
use App\Models\User;
use App\Traits\Processor;
use Illuminate\Foundation\Application;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PaystackController extends Controller
{
    use Processor;

    private PaymentRequest $payment;
    private $user;

    public function __construct(PaymentRequest $payment, User $user)
    {
        $config = $this->payment_config('paystack', 'payment_config');
        $values = false;
        if (!is_null($config) && $config->mode == 'live') {
            $values = json_decode($config->live_values);
        } elseif (!is_null($config) && $config->mode == 'test') {
            $values = json_decode($config->test_values);
        }

        if ($values) {
            $config = array(
                'publicKey' => env('PAYSTACK_PUBLIC_KEY', $values->public_key),
                'secretKey' => env('PAYSTACK_SECRET_KEY', $values->secret_key),
                'paymentUrl' => env('PAYSTACK_PAYMENT_URL', 'https://api.paystack.co'),
                'merchantEmail' => env('MERCHANT_EMAIL', $values->merchant_email),
            );
            Config::set('paystack', $config);
        }

        $this->payment = $payment;
        $this->user = $user;
    }

    public function index(Request $request): JsonResponse|Redirector|RedirectResponse
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid'
        ]);

        if ($validator->fails()) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_400, null, $this->error_processor($validator)), 400);
        }

        $data = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();
        if (!isset($data)) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
        }

        $payer = json_decode($data['payer_information'], true);

        $url = "https://api.paystack.co/transaction/initialize";

        $fields = [
            'email' => $payer['email'] ?? "customer@email.com",
            'amount' => ($data['payment_amount'] ?? 0) * 100,
            'currency' => $data['currency_code'] ?? 'XOF',
            'reference' => (string)('REF' . time() . 'RANDOM'),
            'callback_url' => route('paystack.callback', ['payment_id' => $data['id']]),
            'metadata' => [
                'payment_id' => $data['id'],
            ]
        ];

        $fields_string = http_build_query($fields);
        $ch = curl_init();

        //set the url, number of POST vars, POST data
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            "Authorization: Bearer " . Config::get('paystack.secretKey'),
            "Cache-Control: no-cache",
        ));

        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = json_decode(curl_exec($ch), true);

        if ($response['status'] && isset($response['data']['authorization_url'])) {
            return redirect($response['data']['authorization_url']);
        }

        return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
    }

    public function handleGatewayCallback(Request $request): Redirector|RedirectResponse
    {
        $paymentDetails = self::getPayStackPaymentData(request: $request);
        $paymentId = $paymentDetails['data']['metadata']['payment_id'] ?? null;
        $payment_data = $paymentId ? $this->payment::where(['id' => $paymentId])->where(['is_paid' => 0])->first() : null;

        // metadata.payment_id is only trustworthy here because it comes from
        // Paystack's own verified transaction record (set server-side at
        // initialize()), not from the callback request. Added as defense-in-depth:
        // the paid amount must match what this payment actually expects, and the
        // gateway reference can't be reused across a different payment_id.
        if ($payment_data
            && $paymentDetails['status'] == true
            && abs(((int)($paymentDetails['data']['amount'] ?? 0)) - (int)round($payment_data->payment_amount * 100)) <= 1
            && !$this->payment::where('transaction_id', $request['trxref'])->exists()
        ) {
            $updated = false;
            DB::transaction(function () use ($payment_data, $request, &$updated) {
                $locked = $this->payment::where(['id' => $payment_data->id])->lockForUpdate()->first();
                if ($locked && !$locked->is_paid) {
                    $locked->payment_method = 'paystack';
                    $locked->is_paid = 1;
                    $locked->transaction_id = $request['trxref'];
                    $locked->save();
                    $updated = true;
                }
            });

            if ($updated) {
                $data = $this->payment::where(['id' => $paymentId])->first();
                if (isset($data) && function_exists($data->success_hook)) {
                    call_user_func($data->success_hook, $data);
                }
                return $this->payment_response($data, 'success');
            }
        }

        $payment_data = $paymentId ? $this->payment::where(['id' => $paymentId])->first() : null;
        if (isset($payment_data) && function_exists($payment_data->failure_hook)) {
            call_user_func($payment_data->failure_hook, $payment_data);
        }
        return $this->payment_response($payment_data, 'fail');
    }

    public function cancel(Request $request): Application|JsonResponse|Redirector|RedirectResponse
    {
        $payment_data = $this->payment::where(['id' => $request['payments_id']])->first();
        if (isset($payment_data) && function_exists($payment_data->failure_hook)) {
            call_user_func($payment_data->failure_hook, $payment_data);
        }
        return $this->payment_response($payment_data, 'fail');
    }

    protected function getPayStackPaymentData(object|array $request): array
    {
        $reference = $request->query('reference');
        $curl = curl_init();

        curl_setopt_array($curl, array(
            CURLOPT_URL => "https://api.paystack.co/transaction/verify/$reference",
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => "",
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => "GET",
            CURLOPT_HTTPHEADER => array(
                "Authorization: Bearer " . Config::get('paystack.secretKey'),
                "Cache-Control: no-cache",
            ),
        ));

        $response = curl_exec($curl);
        $err = curl_error($curl);

        curl_close($curl);
        return json_decode($response, true);
    }
}
