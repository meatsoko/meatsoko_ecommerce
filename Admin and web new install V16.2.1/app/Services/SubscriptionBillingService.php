<?php

namespace App\Services;

use App\Http\Controllers\Payment_Methods\MpesaStkController;
use App\Library\Payer;
use App\Library\Payment as PaymentInfo;
use App\Library\Receiver;
use App\Models\CustomerSubscription;
use App\Models\SubscriptionCharge;
use App\Models\User;
use App\Traits\Payment;
use App\Utils\CustomerManager;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * Charges one due subscription and resolves the result. The wallet path
 * resolves synchronously (in this same call); the M-Pesa path only *starts*
 * here — the STK push is asynchronous, so its charge row stays 'pending'
 * until Safaricom's callback invokes subscription_payment_success/fail
 * (registered as this charge's success/failure hook), which call back into
 * markSuccess()/markFailed() below.
 *
 * Retry policy (confirmed product decision): up to 2 consecutive failures
 * are retried the next day; a 3rd failure pauses the subscription rather
 * than cancelling it or retrying forever.
 */
class SubscriptionBillingService
{
    use Payment;

    private const MAX_FAILED_ATTEMPTS = 2;

    public function __construct(private readonly SubscriptionOrderBuilder $orderBuilder)
    {
    }

    public function chargeSubscription(CustomerSubscription $subscription): void
    {
        $plan = $subscription->plan;
        $charge = SubscriptionCharge::create([
            'customer_subscription_id' => $subscription->id,
            'amount' => $plan->price,
            'payment_method' => $subscription->payment_method,
            'status' => 'pending',
            'attempted_at' => now(),
        ]);

        if ($subscription->payment_method === 'wallet') {
            $this->chargeWallet($subscription, $charge);
        } else {
            $this->chargeMpesa($subscription, $charge);
        }
    }

    private function chargeWallet(CustomerSubscription $subscription, SubscriptionCharge $charge): void
    {
        $amount = $charge->amount;

        $result = DB::transaction(function () use ($subscription, $amount) {
            // Locks the balance read for the duration of the debit — the
            // shared CustomerManager::create_wallet_transaction() helper
            // does not do this itself (see the plan's research notes), so
            // this closes that gap for the money-critical billing path
            // rather than trusting the unlocked check used elsewhere.
            $user = User::where('id', $subscription->customer_id)->lockForUpdate()->first();
            if (!$user || $user->wallet_balance < $amount) {
                return false;
            }

            return CustomerManager::create_wallet_transaction(
                $subscription->customer_id,
                (float)$amount,
                'order_place',
                'Subscription billing: ' . $subscription->plan->title,
            );
        });

        if (!$result) {
            $this->markFailed($subscription, $charge, 'insufficient_wallet_balance');
            return;
        }

        $order = $this->orderBuilder->build($subscription);
        $this->markSuccess($subscription, $charge, $order);
    }

    private function chargeMpesa(CustomerSubscription $subscription, SubscriptionCharge $charge): void
    {
        $customer = $subscription->customer;
        $payer = new Payer($customer->f_name . ' ' . $customer->l_name, $customer->email, $subscription->phone, '');
        $receiver = new Receiver('receiver_name', 'example.png');

        $paymentInfo = new PaymentInfo(
            success_hook: 'subscription_payment_success',
            failure_hook: 'subscription_payment_fail',
            currency_code: getWebConfig(name: 'system_default_currency') ? \App\Models\Currency::find(getWebConfig(name: 'system_default_currency'))->code : 'KES',
            payment_method: 'mpesa_stk',
            payment_platform: 'web',
            payer_id: $subscription->customer_id,
            receiver_id: '100',
            additional_data: ['subscription_charge_id' => $charge->id],
            payment_amount: $charge->amount,
            external_redirect_link: null,
            attribute: 'subscription_charge',
            attribute_id: $charge->id,
        );

        $link = $this->generate_link($payer, $paymentInfo, $receiver);
        if (!$link) {
            $this->markFailed($subscription, $charge, 'mpesa_not_configured');
            return;
        }

        // Pull the payment_id straight back out of the link generate_link()
        // just built (?payment_id=<uuid>) rather than re-querying — it's the
        // same PaymentRequest row generate_link() just inserted.
        parse_str((string)parse_url($link, PHP_URL_QUERY), $query);
        $paymentId = $query['payment_id'] ?? null;
        if (!$paymentId) {
            $this->markFailed($subscription, $charge, 'mpesa_link_generation_failed');
            return;
        }

        $stkRequest = new Request(['payment_id' => $paymentId, 'phone' => $subscription->phone]);
        $response = app(MpesaStkController::class)->stkPush($stkRequest)->getData(true);

        if (empty($response['status'])) {
            $this->markFailed($subscription, $charge, $response['message'] ?? 'mpesa_stk_push_failed');
        }
        // On a successful push, the charge stays 'pending' — resolution
        // happens later via the Safaricom callback → subscription_payment_success/fail.
    }

    public function markSuccess(CustomerSubscription $subscription, SubscriptionCharge $charge, \App\Models\Order $order): void
    {
        $charge->update(['status' => 'success', 'order_id' => $order->id]);
        $subscription->update([
            'next_billing_date' => $this->nextBillingDate($subscription),
            'failed_attempts' => 0,
            'last_charged_at' => now(),
        ]);
    }

    public function markFailed(CustomerSubscription $subscription, SubscriptionCharge $charge, string $reason): void
    {
        $charge->update(['status' => 'failed', 'failure_reason' => $reason]);

        $failedAttempts = $subscription->failed_attempts + 1;
        if ($failedAttempts > self::MAX_FAILED_ATTEMPTS) {
            $subscription->update(['status' => 'paused', 'failed_attempts' => $failedAttempts]);
            return;
        }

        $subscription->update([
            'failed_attempts' => $failedAttempts,
            'next_billing_date' => now()->addDay()->toDateString(),
        ]);
    }

    private function nextBillingDate(CustomerSubscription $subscription): string
    {
        $base = now();
        return $subscription->plan->cadence === 'weekly'
            ? $base->addWeek()->toDateString()
            : $base->addMonthNoOverflow()->toDateString();
    }
}
