<?php

namespace Tests\Feature;

use App\Models\BusinessSetting;
use App\Models\CustomerSubscription;
use App\Models\Product;
use App\Models\ShippingAddress;
use App\Models\SubscriptionPlan;
use App\Models\SubscriptionPlanProduct;
use App\Models\User;
use App\Services\SubscriptionBillingService;
use App\Services\SubscriptionOrderBuilder;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

/**
 * Regression coverage for the subscription billing engine: the wallet charge
 * path (debit, order creation, stock decrement, next-billing-date rollover)
 * and the retry-then-pause failure policy. The M-Pesa path isn't covered
 * here since it depends on an external STK push call — see the plan's
 * verification notes.
 */
class SubscriptionBillingTest extends TestCase
{
    use DatabaseTransactions;

    private function enableWallet(): void
    {
        BusinessSetting::updateOrInsert(['type' => 'wallet_status'], ['value' => 1, 'updated_at' => now()]);
        clearWebConfigCacheKeys();
    }

    private function makeCustomer(float $walletBalance): User
    {
        return User::create([
            'f_name' => 'Test',
            'l_name' => 'Customer',
            'email' => 'sub-customer-' . uniqid() . '@example.com',
            'phone' => '15550100' . random_int(0, 9),
            'password' => bcrypt('password'),
            'is_active' => 1,
            'wallet_balance' => $walletBalance,
        ]);
    }

    private function makeAddress(int $customerId): ShippingAddress
    {
        return ShippingAddress::create([
            'customer_id' => $customerId,
            'is_guest' => 0,
            'contact_person_name' => 'Test Customer',
            'email' => 'sub-customer@example.com',
            'phone' => '15550100000',
            'address' => '123 Test St',
            'city' => 'Testville',
            'zip' => '00000',
            'state' => 'TS',
            'country' => 'Testland',
        ]);
    }

    private function makePlanWithProduct(float $price, string $cadence = 'weekly', int $stock = 10, int $qty = 2): SubscriptionPlan
    {
        $product = Product::create([
            'user_id' => 0,
            'added_by' => 'admin',
            'name' => 'Test Box Item ' . uniqid(),
            'code' => 'SUB' . strtoupper(uniqid()),
            'slug' => 'test-box-item-' . uniqid(),
            'product_type' => 'physical',
            'unit_price' => 10,
            'current_stock' => $stock,
            'minimum_order_qty' => 1,
            'status' => 1,
        ]);

        $plan = SubscriptionPlan::create([
            'title' => 'Test Plan ' . uniqid(),
            'cadence' => $cadence,
            'price' => $price,
            'shipping_cost' => 0,
            'status' => 'active',
        ]);

        SubscriptionPlanProduct::create([
            'subscription_plan_id' => $plan->id,
            'product_id' => $product->id,
            'quantity' => $qty,
        ]);

        return $plan;
    }

    private function makeSubscription(User $customer, SubscriptionPlan $plan, string $paymentMethod = 'wallet'): CustomerSubscription
    {
        $address = $this->makeAddress($customer->id);

        return CustomerSubscription::create([
            'customer_id' => $customer->id,
            'subscription_plan_id' => $plan->id,
            'payment_method' => $paymentMethod,
            'shipping_address_id' => $address->id,
            'status' => 'active',
            'next_billing_date' => now()->toDateString(),
            'failed_attempts' => 0,
        ]);
    }

    private function billingService(): SubscriptionBillingService
    {
        return new SubscriptionBillingService(new SubscriptionOrderBuilder());
    }

    public function test_wallet_charge_succeeds_debits_wallet_and_creates_order(): void
    {
        $this->enableWallet();
        $customer = $this->makeCustomer(walletBalance: 100);
        $plan = $this->makePlanWithProduct(price: 40, stock: 10, qty: 3);
        $subscription = $this->makeSubscription($customer, $plan);

        $this->billingService()->chargeSubscription($subscription);

        $customer->refresh();
        $this->assertEquals(60.0, (float)$customer->wallet_balance);

        $subscription->refresh();
        $this->assertEquals(0, $subscription->failed_attempts);
        $this->assertNotNull($subscription->last_charged_at);
        // weekly cadence -> next billing date rolled forward ~7 days
        $this->assertTrue($subscription->next_billing_date->gt(now()->toDateString()));

        $charge = $subscription->charges()->latest('id')->first();
        $this->assertEquals('success', $charge->status);
        $this->assertNotNull($charge->order_id);

        $order = \App\Models\Order::find($charge->order_id);
        $this->assertNotNull($order, 'A real order must be created for a successful wallet charge.');
        $this->assertEquals(40.0, (float)$order->order_amount);

        $planProduct = $plan->products->first();
        $product = Product::find($planProduct->product_id);
        $this->assertEquals(10 - 3, $product->current_stock, 'Stock must be decremented by the box quantity.');
    }

    public function test_wallet_charge_with_insufficient_balance_fails_and_leaves_wallet_untouched(): void
    {
        $this->enableWallet();
        $customer = $this->makeCustomer(walletBalance: 10);
        $plan = $this->makePlanWithProduct(price: 40);
        $subscription = $this->makeSubscription($customer, $plan);

        $this->billingService()->chargeSubscription($subscription);

        $customer->refresh();
        $this->assertEquals(10.0, (float)$customer->wallet_balance, 'A failed charge must not touch the wallet.');

        $subscription->refresh();
        $this->assertEquals(1, $subscription->failed_attempts);
        $this->assertEquals('active', $subscription->status, 'A single failure retries — it must not pause yet.');
        $this->assertEquals(now()->addDay()->toDateString(), $subscription->next_billing_date->toDateString());

        $charge = $subscription->charges()->latest('id')->first();
        $this->assertEquals('failed', $charge->status);
        $this->assertEquals('insufficient_wallet_balance', $charge->failure_reason);
    }

    public function test_repeated_failures_pause_the_subscription_after_max_attempts(): void
    {
        $this->enableWallet();
        $customer = $this->makeCustomer(walletBalance: 0);
        $plan = $this->makePlanWithProduct(price: 40);
        $subscription = $this->makeSubscription($customer, $plan);

        $service = $this->billingService();
        $service->chargeSubscription($subscription);
        $subscription->refresh();
        $this->assertEquals('active', $subscription->status);

        // Re-fetch as the command would on its next run — chargeSubscription
        // creates a fresh charge row itself, so re-invoking on the same
        // (now-refreshed) subscription simulates the next day's retry.
        $service->chargeSubscription($subscription);
        $subscription->refresh();
        $this->assertEquals('active', $subscription->status, 'Second failure still retries (max is 2).');

        $service->chargeSubscription($subscription);
        $subscription->refresh();
        $this->assertEquals('paused', $subscription->status, 'Third consecutive failure must auto-pause.');
        $this->assertEquals(3, $subscription->failed_attempts);
    }

    public function test_monthly_cadence_advances_next_billing_date_by_a_month(): void
    {
        $this->enableWallet();
        $customer = $this->makeCustomer(walletBalance: 100);
        $plan = $this->makePlanWithProduct(price: 20, cadence: 'monthly');
        $subscription = $this->makeSubscription($customer, $plan);

        $this->billingService()->chargeSubscription($subscription);

        $subscription->refresh();
        $this->assertEquals(now()->addMonthNoOverflow()->toDateString(), $subscription->next_billing_date->toDateString());
    }
}
