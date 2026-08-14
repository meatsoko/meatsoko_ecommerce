<?php

namespace App\Http\Controllers\Affiliate;

use App\Contracts\Repositories\AffiliateWalletRepositoryInterface;
use App\Contracts\Repositories\AffiliateWithdrawRequestRepositoryInterface;
use App\Http\Controllers\Controller;
use App\Models\AffiliateWallet;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WithdrawController extends Controller
{
    public function __construct(
        private readonly AffiliateWalletRepositoryInterface          $affiliateWalletRepo,
        private readonly AffiliateWithdrawRequestRepositoryInterface $withdrawRequestRepo,
    )
    {
        $this->middleware('auth:affiliate');
    }

    public function index(): View
    {
        $affiliate = auth('affiliate')->user();
        $wallet = $this->affiliateWalletRepo->getFirstWhere(params: ['affiliate_id' => $affiliate->id]);
        $withdrawRequests = $this->withdrawRequestRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            filters: ['affiliate_id' => $affiliate->id],
            dataLimit: 15,
        );

        return view('affiliate-views.withdraw.index', compact('wallet', 'withdrawRequests'));
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
            'note' => 'nullable|string|max:255',
        ]);

        $affiliateId = auth('affiliate')->id();
        $amount = (float)$request['amount'];

        // Locks the wallet row for the duration of the transaction so two
        // concurrent withdraw requests can't both read the same pre-write
        // balance and both pass the check below (double-spend) — same
        // reasoning as Vendor\DashboardController::getWithdrawRequest().
        $ok = DB::transaction(function () use ($affiliateId, $amount, $request) {
            $wallet = AffiliateWallet::where('affiliate_id', $affiliateId)->lockForUpdate()->first();
            if (!$wallet || $amount <= 0 || $wallet->total_earning < $amount) {
                return false;
            }

            $this->withdrawRequestRepo->add([
                'affiliate_id' => $affiliateId,
                'amount' => $amount,
                'transaction_note' => $request['note'],
                'approved' => 0,
            ]);

            $wallet->decrement('total_earning', $amount);
            $wallet->increment('pending_withdraw', $amount);

            return true;
        });

        return back()->with($ok ? 'success' : 'error', translate(
            $ok ? 'withdraw_request_has_been_sent' : 'insufficient_balance_or_invalid_amount'
        ));
    }
}
