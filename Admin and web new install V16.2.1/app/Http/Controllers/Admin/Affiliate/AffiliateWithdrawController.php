<?php

namespace App\Http\Controllers\Admin\Affiliate;

use App\Contracts\Repositories\AffiliateWalletRepositoryInterface;
use App\Contracts\Repositories\AffiliateWithdrawRequestRepositoryInterface;
use App\Http\Controllers\BaseController;
use App\Services\AffiliateWithdrawService;
use Devrabiul\ToastMagic\Facades\ToastMagic;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class AffiliateWithdrawController extends BaseController
{
    public function __construct(
        private readonly AffiliateWithdrawRequestRepositoryInterface $withdrawRequestRepo,
        private readonly AffiliateWalletRepositoryInterface          $affiliateWalletRepo,
    )
    {
    }

    public function index(?Request $request, ?string $type = null): View
    {
        $withdrawRequests = $this->withdrawRequestRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            searchValue: $request['searchValue'] ?? null,
            filters: array_filter(['status' => $request['status'] ?? null]),
            relations: ['affiliate'],
            dataLimit: getWebConfig('pagination_limit') ?? 25,
        );

        return view('admin-views.affiliate.withdraw-list', compact('withdrawRequests'));
    }

    public function view(int $id): View|RedirectResponse
    {
        $withdrawRequest = $this->withdrawRequestRepo->getFirstWhere(params: ['id' => $id], relations: ['affiliate']);
        if (!$withdrawRequest) {
            ToastMagic::error(translate('Invalid_withdraw'));
            return back();
        }

        return view('admin-views.affiliate.withdraw-view', compact('withdrawRequest'));
    }

    public function updateStatus(Request $request, int $id, AffiliateWithdrawService $affiliateWithdrawService): RedirectResponse
    {
        $request->validate([
            'approved' => 'required|in:1,2',
            'note' => 'nullable|string|max:255',
        ]);

        $withdrawRequest = $this->withdrawRequestRepo->getFirstWhere(params: ['id' => $id]);
        if (!$withdrawRequest || $withdrawRequest->approved != 0) {
            ToastMagic::error(translate('Invalid_withdraw'));
            return back();
        }

        $wallet = $this->affiliateWalletRepo->getFirstWhere(params: ['affiliate_id' => $withdrawRequest->affiliate_id]);
        if (!$wallet) {
            ToastMagic::error(translate('Invalid_withdraw'));
            return back();
        }

        $formatData = $affiliateWithdrawService->getUpdateData(request: $request, wallet: $wallet, withdraw: $withdrawRequest);
        $this->affiliateWalletRepo->update(id: (string)$wallet->id, data: $formatData['wallet']);
        $this->withdrawRequestRepo->update(id: (string)$id, data: $formatData['withdraw']);

        ToastMagic::success(translate($request['approved'] == 1 ? 'withdraw_request_has_been_approved_successfully' : 'withdraw_request_has_been_denied_successfully'));
        return redirect()->route('admin.affiliate.withdraw-list');
    }
}
