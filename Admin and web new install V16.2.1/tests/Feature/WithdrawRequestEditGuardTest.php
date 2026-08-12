<?php

namespace Tests\Feature;

use App\Models\Seller;
use App\Models\SellerWallet;
use App\Models\WithdrawalMethod;
use App\Models\WithdrawRequest;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

/**
 * Regression coverage for the 2026-08-11 audit finding (High, H3): editing an
 * already-approved withdraw request applied wallet math that assumed the
 * amount was still sitting in pending_withdraw — true for a manually-pending
 * request, but not for one that was auto-approved (funds went straight to
 * withdrawn). Editing an approved request must now be rejected server-side.
 */
class WithdrawRequestEditGuardTest extends TestCase
{
    use DatabaseTransactions;

    public function test_editing_an_approved_withdraw_request_is_rejected_and_wallet_is_untouched(): void
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
            'withdrawn' => 100,
            'commission_given' => 0,
            'total_earning' => 50,
            'pending_withdraw' => 0, // auto-approved requests never touch this
            'delivery_charge_earned' => 0,
            'collected_cash' => 0,
        ]);

        $method = WithdrawalMethod::create([
            'method_name' => 'Test Bank',
            'method_fields' => [],
            'is_default' => 0,
            'is_active' => 1,
            'vendor_status' => 1,
            'customer_status' => 1,
        ]);

        $withdrawRequest = WithdrawRequest::create([
            'seller_id' => $seller->id,
            'amount' => 20,
            'withdrawal_method_id' => $method->id,
            'withdrawal_method_fields' => json_encode([]),
            'approved' => 1, // already auto-approved — funds already in withdrawn
        ]);

        $response = $this->actingAs($seller, 'seller')->post(route('vendor.dashboard.withdraw-request-update'), [
            'withdraw_request_id' => $withdrawRequest->id,
            'withdraw_method' => $method->id,
            'amount' => 15,
        ]);

        $response->assertRedirect();

        $wallet->refresh();
        $this->assertEquals(0.0, (float)$wallet->pending_withdraw, 'pending_withdraw must stay untouched — the request never put funds there.');
        $this->assertEquals(50.0, (float)$wallet->total_earning, 'total_earning must be untouched by a rejected edit.');

        $withdrawRequest->refresh();
        $this->assertEquals(1, (int)$withdrawRequest->approved, 'An already-approved request must not be silently un-approved by an edit.');
        $this->assertEquals(20.0, (float)$withdrawRequest->amount, 'The original amount must be unchanged.');
    }

    public function test_editing_a_still_pending_withdraw_request_is_allowed(): void
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
            'total_earning' => 30,
            'pending_withdraw' => 20, // the pending request's amount does sit here
            'delivery_charge_earned' => 0,
            'collected_cash' => 0,
        ]);

        $method = WithdrawalMethod::create([
            'method_name' => 'Test Bank',
            'method_fields' => [],
            'is_default' => 0,
            'is_active' => 1,
            'vendor_status' => 1,
            'customer_status' => 1,
        ]);

        $withdrawRequest = WithdrawRequest::create([
            'seller_id' => $seller->id,
            'amount' => 20,
            'withdrawal_method_id' => $method->id,
            'withdrawal_method_fields' => json_encode([]),
            'approved' => 0, // still pending manual review
        ]);

        $response = $this->actingAs($seller, 'seller')->post(route('vendor.dashboard.withdraw-request-update'), [
            'withdraw_request_id' => $withdrawRequest->id,
            'withdraw_method' => $method->id,
            'amount' => 15,
        ]);

        $response->assertRedirect();

        $wallet->refresh();
        // total_earning (30) + original amount (20) - new amount (15) = 35
        $this->assertEquals(35.0, (float)$wallet->total_earning);
        // pending_withdraw (20) - original amount (20) + new amount (15) = 15
        $this->assertEquals(15.0, (float)$wallet->pending_withdraw);

        $withdrawRequest->refresh();
        $this->assertEquals(0, (int)$withdrawRequest->approved);
    }
}
