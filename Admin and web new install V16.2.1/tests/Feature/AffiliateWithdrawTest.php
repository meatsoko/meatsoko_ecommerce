<?php

namespace Tests\Feature;

use App\Models\Affiliate;
use App\Models\AffiliateWallet;
use App\Models\AffiliateWithdrawRequest;
use App\Services\AffiliateWithdrawService;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\Request;
use Tests\TestCase;

/**
 * Regression coverage for the affiliate withdrawal flow: requesting a
 * withdrawal must move funds from total_earning to pending_withdraw (never
 * exceeding the available balance), and an admin decision must move the
 * amount on from there to either withdrawn (approve) or back to
 * total_earning (deny) — mirrors WithdrawRequestCreateTest's vendor coverage
 * for the same class of bug (unlocked/ungated wallet math).
 */
class AffiliateWithdrawTest extends TestCase
{
    use DatabaseTransactions;

    private function makeApprovedAffiliateWithWallet(float $totalEarning): array
    {
        $affiliate = Affiliate::create([
            'f_name' => 'Test',
            'l_name' => 'Affiliate',
            'email' => 'affiliate-' . uniqid() . '@example.com',
            'phone' => '15550100' . random_int(0, 9),
            'password' => bcrypt('password'),
            'affiliate_code' => 'AFF' . strtoupper(uniqid()),
            'status' => 'approved',
        ]);

        $wallet = AffiliateWallet::create([
            'affiliate_id' => $affiliate->id,
            'total_earning' => $totalEarning,
            'pending_withdraw' => 0,
            'withdrawn' => 0,
        ]);

        return [$affiliate, $wallet];
    }

    public function test_withdrawal_within_balance_succeeds_and_debits_the_wallet(): void
    {
        [$affiliate, $wallet] = $this->makeApprovedAffiliateWithWallet(100);

        $response = $this->actingAs($affiliate, 'affiliate')->post(route('affiliate.withdraw.store'), [
            'amount' => 60,
        ]);

        $response->assertRedirect();
        $wallet->refresh();
        $this->assertEquals(40.0, (float)$wallet->total_earning);
        $this->assertEquals(60.0, (float)$wallet->pending_withdraw);
        $this->assertEquals(1, AffiliateWithdrawRequest::where('affiliate_id', $affiliate->id)->count());
    }

    public function test_withdrawal_exceeding_balance_is_rejected_and_wallet_is_untouched(): void
    {
        [$affiliate, $wallet] = $this->makeApprovedAffiliateWithWallet(40);

        $response = $this->actingAs($affiliate, 'affiliate')->post(route('affiliate.withdraw.store'), [
            'amount' => 60, // more than the 40 available
        ]);

        $response->assertRedirect();
        $wallet->refresh();
        $this->assertEquals(40.0, (float)$wallet->total_earning, 'A withdrawal over balance must not touch the wallet.');
        $this->assertEquals(0.0, (float)$wallet->pending_withdraw);
        $this->assertEquals(0, AffiliateWithdrawRequest::where('affiliate_id', $affiliate->id)->count());
    }

    public function test_admin_approval_moves_amount_from_pending_to_withdrawn(): void
    {
        [, $wallet] = $this->makeApprovedAffiliateWithWallet(40);
        $wallet->update(['total_earning' => 40, 'pending_withdraw' => 60, 'withdrawn' => 0]);
        $withdraw = AffiliateWithdrawRequest::create([
            'affiliate_id' => $wallet->affiliate_id,
            'amount' => 60,
            'approved' => 0,
        ]);

        $service = new AffiliateWithdrawService();
        $formatData = $service->getUpdateData(
            request: new Request(['approved' => 1, 'note' => 'paid via bank transfer']),
            wallet: $wallet,
            withdraw: $withdraw,
        );

        $this->assertEquals(0.0, $formatData['wallet']['pending_withdraw']);
        $this->assertEquals(60.0, $formatData['wallet']['withdrawn']);
        $this->assertArrayNotHasKey('total_earning', $formatData['wallet'], 'Approval must not touch total_earning — the amount already left it at request time.');
        $this->assertEquals(1, $formatData['withdraw']['approved']);
    }

    public function test_admin_denial_refunds_amount_from_pending_to_total_earning(): void
    {
        [, $wallet] = $this->makeApprovedAffiliateWithWallet(40);
        $wallet->update(['total_earning' => 40, 'pending_withdraw' => 60, 'withdrawn' => 0]);
        $withdraw = AffiliateWithdrawRequest::create([
            'affiliate_id' => $wallet->affiliate_id,
            'amount' => 60,
            'approved' => 0,
        ]);

        $service = new AffiliateWithdrawService();
        $formatData = $service->getUpdateData(
            request: new Request(['approved' => 2, 'note' => 'invalid bank details']),
            wallet: $wallet,
            withdraw: $withdraw,
        );

        $this->assertEquals(0.0, $formatData['wallet']['pending_withdraw']);
        $this->assertEquals(100.0, $formatData['wallet']['total_earning'], 'Denial must refund the amount back to the available balance.');
        $this->assertArrayNotHasKey('withdrawn', $formatData['wallet'], 'Denial must not touch withdrawn.');
        $this->assertEquals(2, $formatData['withdraw']['approved']);
    }
}
