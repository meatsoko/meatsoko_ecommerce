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

/**
 * Lipa Na M-Pesa Online (STK Push). Flow: index() renders the phone-number
 * prompt -> stkPush() asks Safaricom to prompt the customer's phone -> the
 * customer enters their PIN on-device -> Safaricom POSTs the result to
 * callback() -> the browser, which has been polling status(), picks up the
 * paid flag and redirects.
 */
class MpesaStkController extends Controller
{
    use Processor;

    private const REQUEST_TIMEOUT = 20;
    private const TOKEN_CACHE_TTL = 3500;
    private const PUSH_LOCK_TTL = 15;

    private PaymentRequest $payment;
    private $user;
    private ?string $consumer_key = null;
    private ?string $consumer_secret = null;
    private ?string $shortcode = null;
    private ?string $passkey = null;
    private string $shortcode_type = 'paybill';
    private string $base_url = 'https://sandbox.safaricom.co.ke';

    public function __construct(PaymentRequest $payment, User $user)
    {
        $this->payment = $payment;
        $this->user = $user;

        $config = $this->payment_config('mpesa_stk', 'payment_config');
        if (is_null($config)) {
            return;
        }

        $values = $config->mode == 'live' ? json_decode($config->live_values) : json_decode($config->test_values);
        if (!$values) {
            return;
        }

        $this->consumer_key = $values->consumer_key ?? null;
        $this->consumer_secret = $values->consumer_secret ?? null;
        $this->shortcode = $values->shortcode ?? null;
        $this->passkey = $values->passkey ?? null;
        $this->shortcode_type = $values->shortcode_type ?? 'paybill';
        $this->base_url = $config->mode == 'live' ? 'https://api.safaricom.co.ke' : 'https://sandbox.safaricom.co.ke';
    }

    private function isConfigured(): bool
    {
        return $this->consumer_key && $this->consumer_secret && $this->shortcode && $this->passkey;
    }

    private function shortReference(string $paymentId): string
    {
        return 'MS' . strtoupper(substr(str_replace('-', '', $paymentId), -8));
    }

    /**
     * Accepts 07XXXXXXXX, 7XXXXXXXX, or 254XXXXXXXXX and normalizes to
     * 254XXXXXXXXX (what Daraja expects for PartyA/PhoneNumber). Returns
     * null for anything that isn't a plausible Kenyan mobile number, so
     * stkPush() can reject it before spending an API call on it.
     */
    private function normalizePhone(string $phone): ?string
    {
        $digits = preg_replace('/\D/', '', $phone);

        if (str_starts_with($digits, '254') && strlen($digits) === 12) {
            return $digits;
        }
        if (str_starts_with($digits, '0') && strlen($digits) === 10) {
            return '254' . substr($digits, 1);
        }
        if (strlen($digits) === 9) {
            return '254' . $digits;
        }

        return null;
    }

    /**
     * Caches the OAuth token on success only - the old implementation cached
     * Cache::remember()'s return value unconditionally, which meant a single
     * transient failure against Safaricom's OAuth endpoint got memoized as
     * "no token" for the full TTL and silently broke STK push for up to an
     * hour even after Safaricom recovered.
     */
    private function getAccessToken(): ?string
    {
        $cacheKey = 'mpesa_stk_access_token_' . $this->shortcode;
        $cached = Cache::get($cacheKey);
        if ($cached) {
            return $cached;
        }

        $url = curl_init($this->base_url . '/oauth/v1/generate?grant_type=client_credentials');
        curl_setopt($url, CURLOPT_HTTPHEADER, ['Content-Type:application/json']);
        curl_setopt($url, CURLOPT_USERPWD, $this->consumer_key . ':' . $this->consumer_secret);
        curl_setopt($url, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($url, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_setopt($url, CURLOPT_CONNECTTIMEOUT, 10);
        curl_setopt($url, CURLOPT_TIMEOUT, self::REQUEST_TIMEOUT);
        $result = curl_exec($url);
        $curlError = curl_error($url);
        curl_close($url);

        if ($result === false) {
            Log::error('Mpesa STK: OAuth request failed', ['error' => $curlError]);
            return null;
        }

        $token = json_decode($result, true)['access_token'] ?? null;
        if ($token) {
            Cache::put($cacheKey, $token, self::TOKEN_CACHE_TTL);
        }

        return $token;
    }

    public function index(Request $request): View|Factory|JsonResponse|Application
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid',
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

        if (!$this->isConfigured()) {
            return response()->json(['status' => 0, 'message' => translate('mpesa_is_not_configured_properly')]);
        }

        $phone = $this->normalizePhone($request['phone']);
        if (!$phone) {
            return response()->json(['status' => 0, 'message' => translate('please_enter_a_valid_mpesa_phone_number')]);
        }

        // Guards against the customer (or a double-clicked button) firing a
        // second STK push while the first is still on the customer's phone
        // awaiting their PIN. Held for the duration of a push attempt and
        // released early on every failure path below so a genuine error
        // doesn't force the customer to wait out the full TTL to retry.
        $lock = Cache::lock('mpesa_stk_push_lock_' . $data->id, self::PUSH_LOCK_TTL);
        if (!$lock->get()) {
            return response()->json([
                'status' => 0,
                'message' => translate('stk_push_already_sent_check_your_phone'),
            ]);
        }

        $token = $this->getAccessToken();
        if (!$token) {
            $lock->release();
            return response()->json(['status' => 0, 'message' => translate('unable_to_reach_mpesa_please_try_again')]);
        }

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
        curl_setopt($url, CURLOPT_CONNECTTIMEOUT, 10);
        curl_setopt($url, CURLOPT_TIMEOUT, self::REQUEST_TIMEOUT);
        $result = curl_exec($url);
        $curlError = curl_error($url);
        curl_close($url);

        if ($result === false) {
            $lock->release();
            Log::error('Mpesa STK push: request to Safaricom failed', ['payment_id' => $data->id, 'error' => $curlError]);
            return response()->json(['status' => 0, 'message' => translate('unable_to_reach_mpesa_please_try_again')]);
        }

        $response = json_decode($result, true);

        if (isset($response['ResponseCode']) && $response['ResponseCode'] == '0') {
            $additionalData = json_decode($data->additional_data, true) ?? [];
            $additionalData['mpesa_checkout_request_id'] = $response['CheckoutRequestID'] ?? null;
            $additionalData['mpesa_merchant_request_id'] = $response['MerchantRequestID'] ?? null;
            $this->payment::where(['id' => $data->id])->update(['additional_data' => json_encode($additionalData)]);

            Log::info('Mpesa STK push accepted by Safaricom, awaiting callback', [
                'payment_id' => $data->id,
                'checkout_request_id' => $response['CheckoutRequestID'] ?? null,
                'callback_url' => $requestBody['CallBackURL'],
            ]);

            return response()->json([
                'status' => 1,
                'message' => translate('stk_push_sent_check_your_phone'),
            ]);
        }

        $lock->release();
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

        Log::info('Mpesa STK callback received', [
            'payment_id' => $payment_id,
            'ip' => $request->ip(),
            'payload' => $payload,
        ]);

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

            // The result is in, one way or another - free the push lock now
            // rather than making a "resend" wait out the rest of its TTL.
            Cache::lock('mpesa_stk_push_lock_' . $payment_id, self::PUSH_LOCK_TTL)->forceRelease();

            if (($callback['ResultCode'] ?? null) !== 0) {
                Log::info('Mpesa STK push not completed by customer', [
                    'payment_id' => $payment_id,
                    'result_code' => $callback['ResultCode'] ?? null,
                    'result_desc' => $callback['ResultDesc'] ?? null,
                ]);
                if (!empty($data->failure_hook) && function_exists($data->failure_hook)) {
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
            if ($paidData && !empty($paidData->success_hook) && function_exists($paidData->success_hook)) {
                call_user_func($paidData->success_hook, $paidData);
            }

            Log::info('Mpesa STK payment confirmed', ['payment_id' => $payment_id, 'receipt' => $receiptNumber]);

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
