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
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class MpesaStkController extends Controller
{
    use Processor;

    private PaymentRequest $payment;
    private $user;
    private $consumer_key;
    private $consumer_secret;
    private $shortcode;
    private $passkey;
    private $shortcode_type;
    private $base_url;

    public function __construct(PaymentRequest $payment, User $user)
    {
        $config = $this->payment_config('mpesa_stk', 'payment_config');
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
            $this->passkey = $values->passkey;
            $this->shortcode_type = $values->shortcode_type ?? 'paybill';
            $this->base_url = ($config->mode == 'live') ? 'https://api.safaricom.co.ke' : 'https://sandbox.safaricom.co.ke';
        }

        $this->payment = $payment;
        $this->user = $user;
    }

    private function shortReference(string $paymentId): string
    {
        return 'MS' . strtoupper(substr(str_replace('-', '', $paymentId), -8));
    }

    private function getAccessToken(): ?string
    {
        return Cache::remember('mpesa_stk_access_token_' . $this->shortcode, 3500, function () {
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

    private function normalizePhone(string $phone): string
    {
        $phone = preg_replace('/\D/', '', $phone);
        if (str_starts_with($phone, '0')) {
            return '254' . substr($phone, 1);
        }
        if (str_starts_with($phone, '254')) {
            return $phone;
        }
        return '254' . $phone;
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

        return view('payment.mpesa-stk', compact('data', 'payer'));
    }

    public function stkPush(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid',
            'phone' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_400, null, $this->error_processor($validator)), 400);
        }

        $data = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();
        if (!isset($data)) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
        }

        if (!$this->shortcode || !$this->passkey) {
            return response()->json(['status' => 0, 'message' => translate('mpesa_is_not_configured_properly')]);
        }

        $token = $this->getAccessToken();
        if (!$token) {
            return response()->json(['status' => 0, 'message' => translate('unable_to_reach_mpesa_please_try_again')]);
        }

        $phone = $this->normalizePhone($request['phone']);
        $timestamp = now()->format('YmdHis');
        $password = base64_encode($this->shortcode . $this->passkey . $timestamp);

        $requestBody = [
            'BusinessShortCode' => $this->shortcode,
            'Password' => $password,
            'Timestamp' => $timestamp,
            'TransactionType' => $this->shortcode_type === 'till' ? 'CustomerBuyGoodsOnline' : 'CustomerPayBillOnline',
            'Amount' => (int)round($data->payment_amount),
            'PartyA' => $phone,
            'PartyB' => $this->shortcode,
            'PhoneNumber' => $phone,
            'CallBackURL' => route('mpesa-stk.callback', ['payment_id' => $data->id]),
            'AccountReference' => $this->shortReference($data->id),
            'TransactionDesc' => 'Order payment',
        ];

        $url = curl_init($this->base_url . '/mpesa/stkpush/v1/processrequest');
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

        $response = json_decode($result, true);

        if (isset($response['ResponseCode']) && $response['ResponseCode'] == '0') {
            $additionalData = json_decode($data->additional_data, true) ?? [];
            $additionalData['mpesa_checkout_request_id'] = $response['CheckoutRequestID'] ?? null;
            $additionalData['mpesa_merchant_request_id'] = $response['MerchantRequestID'] ?? null;
            $this->payment::where(['id' => $data->id])->update(['additional_data' => json_encode($additionalData)]);

            return response()->json([
                'status' => 1,
                'message' => translate('stk_push_sent_check_your_phone'),
            ]);
        }

        Log::warning('Mpesa STK push failed', ['payment_id' => $data->id, 'response' => $response]);
        return response()->json([
            'status' => 0,
            'message' => $response['errorMessage'] ?? translate('unable_to_initiate_mpesa_payment'),
        ]);
    }

    public function callback(Request $request, $payment_id): JsonResponse
    {
        $payload = json_decode($request->getContent(), true);
        $callback = $payload['Body']['stkCallback'] ?? null;

        if (!$callback) {
            return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
        }

        return DB::transaction(function () use ($payment_id, $callback) {
            $data = $this->payment::where(['id' => $payment_id])->where(['is_paid' => 0])->lockForUpdate()->first();
            if (!$data) {
                return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
            }

            $additionalData = json_decode($data->additional_data, true) ?? [];
            if (($additionalData['mpesa_checkout_request_id'] ?? null) !== ($callback['CheckoutRequestID'] ?? null)) {
                Log::warning('Mpesa STK callback CheckoutRequestID mismatch', ['payment_id' => $payment_id]);
                return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
            }

            if (($callback['ResultCode'] ?? null) !== 0) {
                if (isset($data->failure_hook) && function_exists($data->failure_hook)) {
                    call_user_func($data->failure_hook, $data);
                }
                return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
            }

            $items = collect($callback['CallbackMetadata']['Item'] ?? [])->keyBy('Name');
            $paidAmount = $items->get('Amount')['Value'] ?? null;
            $receiptNumber = $items->get('MpesaReceiptNumber')['Value'] ?? null;

            if ($paidAmount === null || abs((float)$paidAmount - (float)$data->payment_amount) > 1) {
                Log::warning('Mpesa STK amount mismatch, payment not marked as paid.', [
                    'payment_id' => $payment_id,
                    'expected' => $data->payment_amount,
                    'paid' => $paidAmount,
                ]);
                return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
            }

            $this->payment::where(['id' => $payment_id])->update([
                'payment_method' => 'mpesa_stk',
                'is_paid' => 1,
                'transaction_id' => $receiptNumber,
            ]);

            $paidData = $this->payment::where(['id' => $payment_id])->first();
            if (isset($paidData) && function_exists($paidData->success_hook)) {
                call_user_func($paidData->success_hook, $paidData);
            }

            return response()->json(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
        });
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
