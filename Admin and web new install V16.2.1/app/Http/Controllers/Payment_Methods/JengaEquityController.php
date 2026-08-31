<?php

namespace App\Http\Controllers\Payment_Methods;

use App\Models\PaymentRequest;
use App\Models\User;
use App\Traits\Processor;
use Carbon\Carbon;
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
use Throwable;

/**
 * Equity Bank push-to-pay via Jenga/Finserve's Equitel STK/USSD Push API.
 * Flow mirrors MpesaStkController: index() renders the phone-number prompt
 * -> push() asks Finserve to prompt the customer's Equitel line -> the
 * customer confirms on-device -> Finserve POSTs the result to callback() ->
 * the browser, which has been polling status(), picks up the paid flag and
 * redirects.
 *
 * Only works for customers with an Equitel-linked Equity account - this is
 * not a generic "any bank" push. API contract per developer.jengahq.io
 * (Generate Signature guide, Developer Quickstart, Equitel STK/USSD Push
 * reference) as of 2026-08.
 */
class JengaEquityController extends Controller
{
    use Processor;

    private const REQUEST_TIMEOUT = 20;
    private const TOKEN_CACHE_FALLBACK_TTL = 3000;
    private const PUSH_LOCK_TTL = 15;

    private PaymentRequest $payment;
    private $user;
    private ?string $api_key = null;
    private ?string $merchant_code = null;
    private ?string $consumer_secret = null;
    private ?string $account_number = null;
    private ?string $merchant_name = null;
    private ?string $country_code = null;
    private ?string $private_key = null;
    private string $base_url = 'https://uat.finserve.africa';

    public function __construct(PaymentRequest $payment, User $user)
    {
        $this->payment = $payment;
        $this->user = $user;

        $config = $this->payment_config('jenga_equity', 'payment_config');
        if (is_null($config)) {
            return;
        }

        $values = $config->mode == 'live' ? json_decode($config->live_values) : json_decode($config->test_values);
        if (!$values) {
            return;
        }

        $this->api_key = $values->api_key ?? null;
        $this->merchant_code = $values->merchant_code ?? null;
        $this->consumer_secret = $values->consumer_secret ?? null;
        $this->account_number = $values->account_number ?? null;
        $this->merchant_name = $values->merchant_name ?? null;
        $this->country_code = $values->country_code ?? null;
        // Admin stores the PEM as a single line with literal \n line breaks
        // (a plain text input can't hold real newlines) - normalize before
        // handing it to openssl.
        $this->private_key = isset($values->private_key) ? str_replace('\\n', "\n", $values->private_key) : null;
        $this->base_url = $config->mode == 'live' ? 'https://api.finserve.africa' : 'https://uat.finserve.africa';
    }

    private function isConfigured(): bool
    {
        return $this->api_key && $this->merchant_code && $this->consumer_secret
            && $this->account_number && $this->merchant_name && $this->country_code && $this->private_key;
    }

    private function shortReference(string $paymentId): string
    {
        return 'JE' . strtoupper(substr(str_replace('-', '', $paymentId), -8));
    }

    /**
     * Accepts 07XXXXXXXX, 7XXXXXXXX, or 254XXXXXXXXX and normalizes to
     * 254XXXXXXXXX (what Finserve expects for payment.mobileNumber).
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
     * Signs a field-concatenated string with the merchant's own RSA private
     * key (SHA-256, PKCS#1 v1.5) per Jenga's "Generate Signature" guide, and
     * returns the base64-encoded signature for the Signature header.
     */
    private function sign(string $data): ?string
    {
        $key = openssl_pkey_get_private($this->private_key);
        if ($key === false) {
            Log::error('Jenga Equity: invalid private key, cannot sign request');
            return null;
        }

        $signed = openssl_sign($data, $signature, $key, OPENSSL_ALGO_SHA256);
        if (!$signed) {
            Log::error('Jenga Equity: openssl_sign failed');
            return null;
        }

        return base64_encode($signature);
    }

    /**
     * Caches the access token on success only - same rationale as Mpesa's
     * getAccessToken(): a transient auth failure must not get memoized as
     * "no token" for the rest of the TTL. TTL is derived from Finserve's
     * `expiresIn` timestamp where possible, otherwise falls back to a fixed
     * duration comfortably inside a typical token lifetime.
     */
    private function getAccessToken(): ?string
    {
        $cacheKey = 'jenga_equity_access_token_' . $this->merchant_code;
        $cached = Cache::get($cacheKey);
        if ($cached) {
            return $cached;
        }

        $url = curl_init($this->base_url . '/authentication/api/v3/authenticate/merchant');
        curl_setopt($url, CURLOPT_HTTPHEADER, [
            'Content-Type:application/json',
            'Api-Key:' . $this->api_key,
        ]);
        curl_setopt($url, CURLOPT_CUSTOMREQUEST, 'POST');
        curl_setopt($url, CURLOPT_POSTFIELDS, json_encode([
            'merchantCode' => $this->merchant_code,
            'consumerSecret' => $this->consumer_secret,
        ]));
        curl_setopt($url, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($url, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_setopt($url, CURLOPT_CONNECTTIMEOUT, 10);
        curl_setopt($url, CURLOPT_TIMEOUT, self::REQUEST_TIMEOUT);
        $result = curl_exec($url);
        $curlError = curl_error($url);
        curl_close($url);

        if ($result === false) {
            Log::error('Jenga Equity: auth request failed', ['error' => $curlError]);
            return null;
        }

        $response = json_decode($result, true);
        $token = $response['accessToken'] ?? null;
        if (!$token) {
            Log::error('Jenga Equity: auth response missing accessToken', ['response' => $response]);
            return null;
        }

        $ttl = self::TOKEN_CACHE_FALLBACK_TTL;
        if (!empty($response['expiresIn'])) {
            try {
                $seconds = (int)now()->diffInSeconds(Carbon::parse($response['expiresIn']), false);
                if ($seconds > 60) {
                    $ttl = $seconds - 60;
                }
            } catch (Throwable $e) {
                // Unparseable expiresIn - keep the fallback TTL.
            }
        }

        Cache::put($cacheKey, $token, $ttl);

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

        return view('payment.jenga-equity', compact('data', 'payer'));
    }

    public function push(Request $request): JsonResponse
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
            return response()->json(['status' => 0, 'message' => translate('jenga_equity_is_not_configured_properly')]);
        }

        $phone = $this->normalizePhone($request['phone']);
        if (!$phone) {
            return response()->json(['status' => 0, 'message' => translate('please_enter_a_valid_equitel_phone_number')]);
        }

        // Same guard as Mpesa: block a double-clicked button from firing a
        // second push while the first is still awaiting the customer's PIN.
        $lock = Cache::lock('jenga_equity_push_lock_' . $data->id, self::PUSH_LOCK_TTL);
        if (!$lock->get()) {
            return response()->json([
                'status' => 0,
                'message' => translate('stk_push_already_sent_check_your_phone'),
            ]);
        }

        $token = $this->getAccessToken();
        if (!$token) {
            $lock->release();
            return response()->json(['status' => 0, 'message' => translate('unable_to_reach_equity_please_try_again')]);
        }

        $reference = $this->shortReference($data->id);
        $amount = number_format((float)$data->payment_amount, 2, '.', '');
        $currency = strtoupper($data->currency_code);

        $signature = $this->sign($this->account_number . $reference . $phone . 'Equitel' . $amount . $currency);
        if (!$signature) {
            $lock->release();
            return response()->json(['status' => 0, 'message' => translate('unable_to_initiate_equity_payment')]);
        }

        $requestBody = [
            'merchant' => [
                'countryCode' => $this->country_code,
                'accountNumber' => $this->account_number,
                'name' => $this->merchant_name,
            ],
            'payment' => [
                'ref' => $reference,
                'mobileNumber' => $phone,
                'telco' => 'Equitel',
                'amount' => $amount,
                'currency' => $currency,
                'date' => now()->format('Y-m-d'),
                'callBackUrl' => route('jenga-equity.callback', ['payment_id' => $data->id]),
                'pushType' => 'STK',
            ],
        ];

        $url = curl_init($this->base_url . '/v3-apis/payment-api/v3.0/stkussdpush/initiate');
        curl_setopt($url, CURLOPT_HTTPHEADER, [
            'Content-Type:application/json',
            'Authorization:Bearer ' . $token,
            'Signature:' . $signature,
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
            Log::error('Jenga Equity push: request to Finserve failed', ['payment_id' => $data->id, 'error' => $curlError]);
            return response()->json(['status' => 0, 'message' => translate('unable_to_reach_equity_please_try_again')]);
        }

        $response = json_decode($result, true);

        // code -1 = "acknowledged" per Jenga's docs (push accepted, awaiting
        // the customer's PIN) - not final payment success, which only
        // arrives via callback().
        if (($response['status'] ?? false) === true || ($response['code'] ?? null) == -1) {
            $additionalData = json_decode($data->additional_data, true) ?? [];
            $additionalData['jenga_reference'] = $response['reference'] ?? $reference;
            $additionalData['jenga_transaction_id'] = $response['transactionId'] ?? null;
            $this->payment::where(['id' => $data->id])->update(['additional_data' => json_encode($additionalData)]);

            Log::info('Jenga Equity push accepted by Finserve, awaiting callback', [
                'payment_id' => $data->id,
                'reference' => $response['reference'] ?? $reference,
                'callback_url' => $requestBody['payment']['callBackUrl'],
            ]);

            return response()->json([
                'status' => 1,
                'message' => translate('stk_push_sent_check_your_phone'),
            ]);
        }

        $lock->release();
        Log::warning('Jenga Equity push failed', ['payment_id' => $data->id, 'response' => $response]);
        return response()->json([
            'status' => 0,
            'message' => $response['message'] ?? translate('unable_to_initiate_equity_payment'),
        ]);
    }

    public function callback(Request $request, $payment_id): JsonResponse
    {
        $payload = json_decode($request->getContent(), true) ?? [];

        Log::info('Jenga Equity callback received', [
            'payment_id' => $payment_id,
            'ip' => $request->ip(),
            'payload' => $payload,
        ]);

        return DB::transaction(function () use ($payment_id, $payload) {
            $data = $this->payment::where(['id' => $payment_id])->where(['is_paid' => 0])->lockForUpdate()->first();
            if (!$data) {
                return response()->json(['status' => true, 'message' => 'Accepted']);
            }

            // There is no published Finserve callback-IP allowlist to check
            // against (unlike Safaricom's, which backs mpesa.ip), so the
            // reference match below is the real authenticity check for this
            // callback - it must match the reference we stored right after
            // a push we ourselves initiated.
            $additionalData = json_decode($data->additional_data, true) ?? [];
            $expectedReference = $additionalData['jenga_reference'] ?? null;
            $receivedReference = $payload['transactionReference'] ?? null;

            if (!$expectedReference || $expectedReference !== $receivedReference) {
                Log::warning('Jenga Equity callback reference mismatch', ['payment_id' => $payment_id]);
                return response()->json(['status' => true, 'message' => 'Accepted']);
            }

            // The result is in, one way or another - free the push lock now
            // rather than making a "resend" wait out the rest of its TTL.
            Cache::lock('jenga_equity_push_lock_' . $payment_id, self::PUSH_LOCK_TTL)->forceRelease();

            // Jenga's docs only confirm `status` (boolean) as the success
            // signal on this callback - the `code` field's meaning here is
            // not documented separately from the push-init response, so it
            // isn't relied on. Verify this against a real sandbox payload
            // once credentials exist, using the full payload logged above.
            $succeeded = ($payload['status'] ?? false) === true;
            if (!$succeeded) {
                Log::info('Jenga Equity push not completed by customer', [
                    'payment_id' => $payment_id,
                    'code' => $payload['code'] ?? null,
                    'message' => $payload['message'] ?? null,
                ]);
                if (!empty($data->failure_hook) && function_exists($data->failure_hook)) {
                    call_user_func($data->failure_hook, $data);
                }
                return response()->json(['status' => true, 'message' => 'Accepted']);
            }

            $paidAmount = $payload['debitedAmount'] ?? $payload['requestAmount'] ?? null;
            if ($paidAmount === null || abs((float)$paidAmount - (float)$data->payment_amount) > 1) {
                Log::warning('Jenga Equity amount mismatch, payment not marked as paid.', [
                    'payment_id' => $payment_id,
                    'expected' => $data->payment_amount,
                    'paid' => $paidAmount,
                ]);
                return response()->json(['status' => true, 'message' => 'Accepted']);
            }

            $this->payment::where(['id' => $payment_id])->update([
                'payment_method' => 'jenga_equity',
                'is_paid' => 1,
                'transaction_id' => $payload['telcoReference'] ?? $receivedReference,
            ]);

            $paidData = $this->payment::where(['id' => $payment_id])->first();
            if ($paidData && !empty($paidData->success_hook) && function_exists($paidData->success_hook)) {
                call_user_func($paidData->success_hook, $paidData);
            }

            Log::info('Jenga Equity payment confirmed', [
                'payment_id' => $payment_id,
                'receipt' => $payload['telcoReference'] ?? null,
            ]);

            return response()->json(['status' => true, 'message' => 'Accepted']);
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
