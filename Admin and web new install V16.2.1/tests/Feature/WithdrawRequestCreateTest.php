<?php

namespace Tests\Feature;

use App\Models\Seller;
use App\Models\SellerWallet;
use App\Models\WithdrawalMethod;
use App\Models\WithdrawRequest;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

/**
 * Regression coverage for the 2026-08-11 audit finding (Critical, C4):
 * withdrawal fast-track auto-approval had no DB transaction or row lock, so
 * a wallet's balance check could be bypassed. True concurrency isn't
 * practical to simulate synchronously in PHPUnit, but this locks down the
 * balance-guard behavior the fix must preserve under normal, sequential use.
 */
class WithdrawRequestCreateTest extends TestCase
{
    use DatabaseTransactions;

    private function makeApprovedSellerWithWallet(float $totalEarning): array
    {
        $seller = Seller::create([
            'f_name' => 'Test',
            'l_name' => 'Vendor',
            'email' => 'vendor-' . uniqid() . '@example.com',
            'phone' => '1555' . random_int(1000000, 9999999),
            'password' => bcrypt('password'),
            'status' => 'approved',
        ]);

        $wallet = SellerWallet::create([
            'seller_id' => $seller->id,
            'withdrawn' => 0,
            'commission_given' => 0,
            'total_earning' => $totalEarning,
            'pending_withdraw' => 0,
            'delivery_charge_earned' => 0,
            'collected_cash' => 0,
        ]);

        return [$seller, $wallet];
    }

    public function test_withdrawal_within_balance_succeeds_and_debits_the_wallet(): void
    {
        [$seller, $wallet] = $this->makeApprovedSellerWithWallet(100);
        $method = WithdrawalMethod::create([
            'method_name' => 'Test Bank', 'method_fields' => [], 'is_default' => 0,
            'is_active' => 1, 'vendor_status' => 1, 'customer_status' => 1,
        ]);

        $response = $this->actingAs($seller, 'seller')->post(route('vendor.dashboard.withdraw-request'), [
            'withdraw_method' => $method->id,
            'amount' => 60,
        ]);

        $response->assertRedirect();
        $wallet->refresh();
        // No strikes on this seller, so the request auto-approves — funds
        // move straight from total_earning to withdrawn.
        $this->assertEquals(40.0, (float)$wallet->total_earning);
        $this->assertEquals(60.0, (float)$wallet->withdrawn);
        $this->assertEquals(1, WithdrawRequest::where('seller_id', $seller->id)->count());
    }

    public function test_withdrawal_exceeding_balance_is_rejected_and_wallet_is_untouched(): void
    {
        [$seller, $wallet] = $this->makeApprovedSellerWithWallet(40);
        $method = WithdrawalMethod::create([
            'method_name' => 'Test Bank', 'method_fields' => [], 'is_default' => 0,
            'is_active' => 1, 'vendor_status' => 1, 'customer_status' => 1,
        ]);

        $response = $this->actingAs($seller, 'seller')->post(route('vendor.dashboard.withdraw-request'), [
            'withdraw_method' => $method->id,
            'amount' => 60, // more than the 40 available
        ]);

        $response->assertRedirect();
        $wallet->refresh();
        $this->assertEquals(40.0, (float)$wallet->total_earning, 'A withdrawal over balance must not touch the wallet.');
        $this->assertEquals(0.0, (float)$wallet->withdrawn);
        $this->assertEquals(0, WithdrawRequest::where('seller_id', $seller->id)->count());
    }
}
