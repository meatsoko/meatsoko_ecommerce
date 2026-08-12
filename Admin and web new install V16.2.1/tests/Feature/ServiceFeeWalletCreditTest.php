<?php

namespace Tests\Feature;

use App\Models\AdminWallet;
use App\Models\Order;
use App\Models\SellerWallet;
use App\Models\Transaction;
use App\Utils\OrderManager;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

/**
 * Regression coverage for the service-fee wallet credit having no
 * idempotency guard (2026-08-11 audit, Medium finding M2) — a reverted-then-
 * redelivered order, or this function running twice, must not double-credit
 * the admin wallet.
 */
class ServiceFeeWalletCreditTest extends TestCase
{
    use DatabaseTransactions;

    public function test_service_fee_is_credited_once_even_if_the_function_runs_twice(): void
    {
        $sellerId = random_int(100000, 999999);
        SellerWallet::create([
            'seller_id' => $sellerId,
            'withdrawn' => 0,
            'commission_given' => 0,
            'total_earning' => 0,
            'pending_withdraw' => 0,
            'delivery_charge_earned' => 0,
            'collected_cash' => 0,
        ]);

        $order = Order::create([
            'order_amount' => 105,
            'shipping_cost' => 0,
            'service_fee' => 5,
            'order_status' => 'delivered',
            'payment_status' => 'paid',
            'admin_commission' => 0,
            'total_tax_amount' => 0,
            'is_shipping_free' => 0,
            'shipping_responsibility' => 'sellerwise_shipping',
            'seller_id' => $sellerId,
            'seller_is' => 'seller',
            'is_guest' => 1,
        ]);

        $adminWalletBefore = AdminWallet::where('admin_id', 1)->first()->service_fee_earned ?? 0;

        OrderManager::getWalletManageOnOrderStatusChange($order, 'seller');
        OrderManager::getWalletManageOnOrderStatusChange($order, 'seller');

        $adminWalletAfter = AdminWallet::where('admin_id', 1)->first()->service_fee_earned;

        $this->assertEquals(
            (float)$adminWalletBefore + 5.0,
            (float)$adminWalletAfter,
            'service_fee_earned should increase by exactly one order\'s service fee, not two.'
        );
        $this->assertEquals(1, Transaction::where(['order_id' => $order->id, 'payment_for' => 'service_fee'])->count());
    }
}
