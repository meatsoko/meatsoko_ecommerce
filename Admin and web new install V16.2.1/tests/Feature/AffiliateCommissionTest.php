<?php

namespace Tests\Feature;

use App\Models\Affiliate;
use App\Models\AffiliateCommission;
use App\Models\AffiliateWallet;
use App\Models\BusinessSetting;
use App\Models\Order;
use App\Models\ShippingAddress;
use App\Utils\OrderManager;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

/**
 * Regression coverage for two bugs found in the 2026-08-11 affiliate-program
 * audit: the commission base amount briefly included the platform's own
 * service fee (overpaying affiliates), and the self-referral guard never
 * ran for guest checkout (letting an affiliate credit themselves).
 */
class AffiliateCommissionTest extends TestCase
{
    use DatabaseTransactions;

    private function enableAffiliateProgram(float $rate = 10): void
    {
        BusinessSetting::updateOrInsert(['type' => 'affiliate_program_status'], ['value' => 1, 'updated_at' => now()]);
        BusinessSetting::updateOrInsert(['type' => 'affiliate_commission_rate'], ['value' => $rate, 'updated_at' => now()]);
        clearWebConfigCacheKeys();
    }

    private function makeAffiliate(array $overrides = []): Affiliate
    {
        return Affiliate::create(array_merge([
            'f_name' => 'Test',
            'l_name' => 'Affiliate',
            'email' => 'affiliate-' . uniqid() . '@example.com',
            'phone' => '15550100' . random_int(0, 9),
            'password' => bcrypt('password'),
            'affiliate_code' => 'AFF' . strtoupper(uniqid()),
            'status' => 'approved',
        ], $overrides));
    }

    private function makeDeliveredOrder(array $overrides = []): Order
    {
        return Order::create(array_merge([
            'order_amount' => 100,
            'shipping_cost' => 10,
            'service_fee' => 5,
            'order_status' => 'delivered',
            'payment_status' => 'paid',
            'is_guest' => 0,
        ], $overrides));
    }

    public function test_commission_base_amount_excludes_shipping_and_service_fee(): void
    {
        $this->enableAffiliateProgram(rate: 10);
        $affiliate = $this->makeAffiliate();
        $order = $this->makeDeliveredOrder([
            'affiliate_id' => $affiliate->id,
            'order_amount' => 105, // $100 product + $0 shipping + $5 service fee
            'shipping_cost' => 0,
            'service_fee' => 5,
        ]);

        OrderManager::generateAffiliateCommission($order);

        $commission = AffiliateCommission::where('order_id', $order->id)->first();
        $this->assertNotNull($commission, 'Commission should have been generated for a delivered order.');
        // Base must be 100 (105 - 0 shipping - 5 service fee), not 105 — the
        // bug this guards against paid commission on the platform's own fee.
        $this->assertEquals(100.0, (float)$commission->order_amount);
        $this->assertEquals(10.0, (float)$commission->amount);

        $wallet = AffiliateWallet::where('affiliate_id', $affiliate->id)->first();
        $this->assertNotNull($wallet);
        $this->assertEquals(10.0, (float)$wallet->total_earning);
    }

    public function test_commission_is_not_generated_twice_for_same_order(): void
    {
        $this->enableAffiliateProgram(rate: 10);
        $affiliate = $this->makeAffiliate();
        $order = $this->makeDeliveredOrder(['affiliate_id' => $affiliate->id]);

        OrderManager::generateAffiliateCommission($order);
        OrderManager::generateAffiliateCommission($order);

        $this->assertEquals(1, AffiliateCommission::where('order_id', $order->id)->count());

        $wallet = AffiliateWallet::where('affiliate_id', $affiliate->id)->first();
        // 100 - 10 shipping - 5 service fee = 85, at 10% = 8.5 — credited once.
        $this->assertEquals(8.5, (float)$wallet->total_earning);
    }

    public function test_no_commission_when_program_disabled(): void
    {
        $this->enableAffiliateProgram(rate: 10);
        BusinessSetting::updateOrInsert(['type' => 'affiliate_program_status'], ['value' => 0, 'updated_at' => now()]);
        clearWebConfigCacheKeys();

        $affiliate = $this->makeAffiliate();
        $order = $this->makeDeliveredOrder(['affiliate_id' => $affiliate->id]);

        OrderManager::generateAffiliateCommission($order);

        $this->assertEquals(0, AffiliateCommission::where('order_id', $order->id)->count());
    }

    public function test_no_commission_when_order_not_delivered(): void
    {
        $this->enableAffiliateProgram(rate: 10);
        $affiliate = $this->makeAffiliate();
        $order = $this->makeDeliveredOrder(['affiliate_id' => $affiliate->id, 'order_status' => 'pending']);

        OrderManager::generateAffiliateCommission($order);

        $this->assertEquals(0, AffiliateCommission::where('order_id', $order->id)->count());
    }

    public function test_self_referral_guard_blocks_guest_checkout_matching_affiliate_contact(): void
    {
        $affiliate = $this->makeAffiliate(['email' => 'self-ref@example.com', 'phone' => '15551234567']);

        $address = ShippingAddress::create([
            'customer_id' => 0,
            'is_guest' => true,
            'contact_person_name' => 'Guest Checkout',
            'email' => 'self-ref@example.com', // same email as the affiliate
            'phone' => '15551234567',
            'address' => '123 Test St',
            'city' => 'Testville',
            'zip' => '00000',
            'state' => 'TS',
            'country' => 'Testland',
        ]);

        request()->cookies->set('affiliate_ref', $affiliate->affiliate_code);

        $resolved = $this->callResolveAffiliateIdForOrder('offline', $address->id);

        $this->assertNull($resolved, 'An affiliate must not be attributed to their own guest checkout.');
    }

    public function test_referral_still_resolves_for_a_different_guest_customer(): void
    {
        $affiliate = $this->makeAffiliate(['email' => 'real-affiliate@example.com', 'phone' => '15559999999']);

        $address = ShippingAddress::create([
            'customer_id' => 0,
            'is_guest' => true,
            'contact_person_name' => 'A Real Customer',
            'email' => 'customer@example.com',
            'phone' => '15550001111',
            'address' => '456 Test Ave',
            'city' => 'Testville',
            'zip' => '00000',
            'state' => 'TS',
            'country' => 'Testland',
        ]);

        request()->cookies->set('affiliate_ref', $affiliate->affiliate_code);

        $resolved = $this->callResolveAffiliateIdForOrder('offline', $address->id);

        $this->assertEquals($affiliate->id, $resolved, 'A genuine referral for a different guest should still attribute normally.');
    }

    private function callResolveAffiliateIdForOrder(mixed $customer, mixed $addressId): ?int
    {
        $method = new \ReflectionMethod(OrderManager::class, 'resolveAffiliateIdForOrder');
        $method->setAccessible(true);
        return $method->invoke(null, $customer, $addressId);
    }
}
