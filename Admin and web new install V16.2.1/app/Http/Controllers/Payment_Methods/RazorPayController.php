<?php

namespace App\Http\Controllers\Payment_Methods;

use App\Models\PaymentRequest;
use App\Models\User;
use App\Traits\Processor;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Razorpay\Api\Api;

class RazorPayController extends Controller
{
    use Processor;

    private PaymentRequest $payment;
    private $user;

    public function __construct(PaymentRequest $payment, User $user)
    {
        $config = $this->payment_config('razor_pay', 'payment_config');
        $razor = false;
        if (!is_null($config) && $config->mode == 'live') {
            $razor = json_decode($config->live_values);
        } elseif (!is_null($config) && $config->mode == 'test') {
            $razor = json_decode($config->test_values);
        }

        if ($razor) {
            $config = array(
                'api_key' => $razor->api_key,
                'api_secret' => $razor->api_secret
            );
            Config::set('razor_config', $config);
        }

        $this->payment = $payment;
        $this->user = $user;
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

        if ($data['additional_data'] != null) {
            $business = json_decode($data['additional_data']);
            $business_name = $business->business_name ?? "my_business";
            $business_logo = $business->business_logo ?? url('/');
        } else {
            $business_name = "my_business";
            $business_logo = url('/');
        }

        return view('payment.razor-pay', compact('data', 'payer', 'business_logo', 'business_name'));
    }

    public function payment(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $input = $request->all();
        $payment_data = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();

        if (!$payment_data || empty($input['razorpay_payment_id']) || !$this->verifyAndCapturePayment($input['razorpay_payment_id'], $payment_data)) {
            if (isset($payment_data) && function_exists($payment_data->failure_hook)) {
                call_user_func($payment_data->failure_hook, $payment_data);
            }
            return $this->payment_response($payment_data, 'fail');
        }

        $data = $this->payment::where(['id' => $request['payment_id']])->first();
        if (isset($data) && function_exists($data->success_hook)) {
            call_user_func($data->success_hook, $data);
        }
        return $this->payment_response($data, 'success');
    }

    public function callback(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $input = $request->all();
        $payment_data = $this->payment::where(['id' => $request->payment_request_id])->where(['is_paid' => 0])->first();

        if ($payment_data && !empty($input['razorpay_payment_id']) && function_exists($payment_data->success_hook)
            && $this->verifyAndCapturePayment($input['razorpay_payment_id'], $payment_data)) {
            $data = $this->payment::where(['id' => $request->payment_request_id])->first();
            call_user_func($data->success_hook, $data);
            return $this->payment_response($data, 'success');
        }
        return $this->payment_response($payment_data ?? $this->payment::where(['id' => $request->payment_request_id])->first(), 'fail');
    }

    /**
     * Verifies a razorpay_payment_id server-side (status + amount) before
     * accepting it, and atomically binds it to exactly one PaymentRequest.
     * Without this, a client could submit a valid-but-unrelated
     * razorpay_payment_id (e.g. from their own small legitimate payment)
     * against an arbitrary payment_request_id and have it marked paid —
     * there was previously no check that the two were ever associated.
     */
    private function verifyAndCapturePayment(string $razorpayPaymentId, $paymentData): bool
    {
        $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));

        try {
            $payment = $api->payment->fetch($razorpayPaymentId);
        } catch (\Exception $exception) {
            return false;
        }

        if (!in_array($payment['status'], ['authorized', 'captured'], true)) {
            return false;
        }

        $expectedAmount = (int)round($paymentData->payment_amount * 100);
        if (abs((int)$payment['amount'] - $expectedAmount) > 1) {
            return false;
        }

        // A razorpay_payment_id already recorded against another payment_request
        // must never be reusable — otherwise the same paid transaction could be
        // replayed to mark a second, unrelated order as paid.
        if ($this->payment::where('transaction_id', $razorpayPaymentId)->exists()) {
            return false;
        }

        try {
            if ($payment['status'] === 'authorized') {
                $api->payment->fetch($razorpayPaymentId)->capture(['amount' => $payment['amount'] - ($payment['fee'] ?? 0)]);
            }
        } catch (\Exception $exception) {
            return false;
        }

        $captured = false;
        DB::transaction(function () use ($razorpayPaymentId, $paymentData, &$captured) {
            $locked = $this->payment::where(['id' => $paymentData->id])->lockForUpdate()->first();
            if ($locked && !$locked->is_paid) {
                $locked->payment_method = 'razor_pay';
                $locked->is_paid = 1;
                $locked->transaction_id = $razorpayPaymentId;
                $locked->save();
                $captured = true;
            }
        });

        return $captured;
    }

    public function cancel(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $payment_data = $this->payment::where(['id' => $request['payment_id']])->first();
        return $this->payment_response($payment_data, 'fail');
    }

    public function createOrder(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $request->validate([
            'payment_request_id' => 'required|uuid',
        ]);

        // The order is created for the amount/currency stored server-side against
        // payment_request_id — never for client-supplied payment_amount/currency_code
        // — so a tampered request can't get a mismatched Razorpay order created for it.
        $payment_data = $this->payment::where(['id' => $request['payment_request_id']])->where(['is_paid' => 0])->first();
        if (!$payment_data) {
            return response()->json(['status' => false, 'message' => translate('Invalid_payment_request')]);
        }

        try {
            $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));

            $razorpayOrder = $api->order->create([
                'receipt' => 'order_' . uniqid(),
                'amount' => (int)round($payment_data->payment_amount * 100),
                'currency' => $payment_data->currency_code,
                'payment_capture' => 1
            ]);

            return response()->json([
                'status' => true,
                'payment_request_id' => $payment_data->id,
                'order_id' => $razorpayOrder['id'],
                'amount' => $razorpayOrder['amount'],
                'currency' => $razorpayOrder['currency']
            ]);
        } catch (\Exception $exception) {
            return response()->json([
                'status' => false,
                'message' => $exception->getMessage()
            ]);
        }
    }

    public function verifyPayment(Request $request): JsonResponse|Redirector|RedirectResponse|Application
    {
        $payment_data = $this->payment::where(['id' => $request['payment_request_id']])->where(['is_paid' => 0])->first();
        if (!$payment_data || empty($request['payment_id'])) {
            return $this->payment_response($payment_data, 'fail');
        }

        $api = new Api(config('razor_config.api_key'), config('razor_config.api_secret'));
        try {
            $api->utility->verifyPaymentSignature([
                'razorpay_order_id' => $request['order_id'],
                'razorpay_payment_id' => $request['payment_id'],
                'razorpay_signature' => $request['signature']
            ]);
        } catch (\Exception $exception) {
            if (function_exists($payment_data->failure_hook)) {
                call_user_func($payment_data->failure_hook, $payment_data);
            }
            return $this->payment_response($payment_data, 'fail');
        }

        if (!$this->verifyAndCapturePayment($request['payment_id'], $payment_data)) {
            if (function_exists($payment_data->failure_hook)) {
                call_user_func($payment_data->failure_hook, $payment_data);
            }
            return $this->payment_response($payment_data, 'fail');
        }

        $data = $this->payment::where(['id' => $request['payment_request_id']])->first();
        if (isset($data) && function_exists($data->success_hook)) {
            call_user_func($data->success_hook, $data);
        }
        return $this->payment_response($data, 'success');
    }
}
