<?php

namespace App\Http\Controllers\Payment_Methods;

use App\Models\PaymentRequest;
use App\Models\User;
use App\Traits\Processor;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class MpesaC2bController extends Controller
{
    use Processor;

    private PaymentRequest $payment;
    private $user;
    private $consumer_key;
    private $consumer_secret;
    private $shortcode;
    private $base_url;

    public function __construct(PaymentRequest $payment, User $user)
    {
        $config = $this->payment_config('mpesa_c2b', 'payment_config');
        $values = false;
        if (!is_null($config) && $config->mode == 'live') {
            $values = json_decode($config->live_values);
        } elseif (!is_null($config) && $config->mode == 'test') {
            $values = json_decode($config->test_values);
        }

        if ($values) {
            $this->consumer_key = $values->consumer_key;
            $this->consumer_secret = $values->consumer_secret;
            $this->shortcode = $values->shortcode;
            $this->base_url = ($config->mode == 'live') ? 'https://api.safaricom.co.ke' : 'https://sandbox.safaricom.co.ke';
        }

        $this->payment = $payment;
        $this->user = $user;
    }

    private function shortReference(string $paymentId): string
    {
        return 'MS' . strtoupper(substr(str_replace('-', '', $paymentId), -8));
    }

    private function findByShortReference(string $reference): ?PaymentRequest
    {
        $hex = strtolower(preg_replace('/[^A-Za-z0-9]/', '', $reference));
        if (str_starts_with($hex, 'ms')) {
            $hex = substr($hex, 2);
        }
        if (strlen($hex) !== 8) {
            return null;
        }

        return $this->payment::whereRaw("REPLACE(id, '-', '') LIKE ?", ['%' . $hex])
            ->where('is_paid', 0)
            ->first();
    }

    private function getAccessToken(): ?string
    {
        return Cache::remember('mpesa_c2b_access_token_' . $this->shortcode, 3500, function () {
            $url = curl_init($this->base_url . '/oauth/v1/generate?grant_type=client_credentials');
            curl_setopt($url, CURLOPT_HTTPHEADER, ['Content-Type:application/json']);
            curl_setopt($url, CURLOPT_USERPWD, $this->consumer_key . ':' . $this->consumer_secret);
            curl_setopt($url, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($url, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
            $result = curl_exec($url);
            curl_close($url);

            $response = json_decode($result, true);
            return $response['access_token'] ?? null;
        });
    }

    public function index(Request $request): View|Factory|JsonResponse|Application
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
        $payer = json_decode($data['payer_information']);
        $shortcode = $this->shortcode;
        $accountReference = $this->shortReference($data->id);

        return view('payment.mpesa-c2b', compact('data', 'payer', 'shortcode', 'accountReference'));
    }

    /**
     * One-time (or admin re-run) registration of the Confirmation/Validation
     * webhook URLs with Safaricom for this Paybill/Till shortcode.
     * Intended to be run via `php artisan mpesa:register-c2b-urls`.
     */
    public function registerUrls(): JsonResponse
    {
        if (!$this->shortcode) {
            return response()->json(['status' => 0, 'message' => translate('mpesa_is_not_configured_properly')]);
        }

        $token = $this->getAccessToken();
        if (!$token) {
            return response()->json(['status' => 0, 'message' => translate('unable_to_reach_mpesa_please_try_again')]);
        }

        $requestBody = [
            'ShortCode' => $this->shortcode,
            'ResponseType' => 'Completed',
            'ConfirmationURL' => route('mpesa-c2b.confirmation'),
            'ValidationURL' => route('mpesa-c2b.validation'),
        ];

        $url = curl_init($this->base_url . '/mpesa/c2b/v2/registerurl');
        curl_setopt($url, CURLOPT_HTTPHEADER, [
            'Content-Type:application/json',
            'Authorization:Bearer ' . $token,
        ]);
        curl_setopt($url, CURLOPT_CUSTOMREQUEST, 'POST');
        curl_setopt($url, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($url, CURLOPT_POSTFIELDS, json_encode($requestBody));
        curl_setopt($url, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        $result = curl_exec($url);
        curl_close($url);

        return response()->json(['status' => 1, 'response' => json_decode($result, true)]);
    }

    public function validation(Request $request): JsonResponse
    {
        $billRefNumber = $request->input('BillRefNumber', '');
        $data = $this->findByShortReference($billRefNumber);

        if (!$data) {
            Log::warning('Mpesa C2B validation rejected: unknown or already-paid reference', ['bill_ref_number' => $billRefNumber]);
            return response()->json(['ResultCode' => 'C2B00016', 'ResultDesc' => 'Rejected']);
        }

        return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
    }

    public function confirmation(Request $request): JsonResponse
    {
        $billRefNumber = $request->input('BillRefNumber', '');
        $transAmount = $request->input('TransAmount');
        $transId = $request->input('TransID');

        $data = $this->findByShortReference($billRefNumber);

        if (!$data) {
            // Money has already moved at this point; we cannot reject a Confirmation.
            // Log for manual admin reconciliation instead.
            Log::warning('Mpesa C2B confirmation for unknown or already-paid reference, funds received but no order matched.', [
                'bill_ref_number' => $billRefNumber,
                'trans_id' => $transId,
                'trans_amount' => $transAmount,
            ]);
            return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Success']);
        }

        if ($transAmount === null || abs((float)$transAmount - (float)$data->payment_amount) > 1) {
            Log::warning('Mpesa C2B amount mismatch, payment not marked as paid.', [
                'payment_id' => $data->id,
                'expected' => $data->payment_amount,
                'paid' => $transAmount,
            ]);
            return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Success']);
        }

        $this->payment::where(['id' => $data->id])->update([
            'payment_method' => 'mpesa_c2b',
            'is_paid' => 1,
            'transaction_id' => $transId,
        ]);

        $paidData = $this->payment::where(['id' => $data->id])->first();
        if (isset($paidData) && function_exists($paidData->success_hook)) {
            call_user_func($paidData->success_hook, $paidData);
        }

        return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Success']);
    }

    public function status(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid',
        ]);
        if ($validator->fails()) {
            return response()->json(['status' => 0]);
        }

        $data = $this->payment::where(['id' => $request['payment_id']])->first();
        if (!$data) {
            return response()->json(['status' => 0]);
        }

        if ($data->is_paid == 1) {
            $redirect = $this->payment_response($data, 'success');
            return response()->json(['status' => 1, 'redirect_url' => $redirect->getTargetUrl()]);
        }

        return response()->json(['status' => 0]);
    }
}
