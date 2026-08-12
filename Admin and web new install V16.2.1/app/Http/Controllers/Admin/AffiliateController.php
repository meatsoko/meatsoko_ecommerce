<?php

namespace App\Http\Controllers\Admin;

use App\Contracts\Repositories\AffiliateRepositoryInterface;
use App\Contracts\Repositories\AffiliateWalletRepositoryInterface;
use App\Contracts\Repositories\BusinessSettingRepositoryInterface;
use App\Http\Controllers\BaseController;
use Devrabiul\ToastMagic\Facades\ToastMagic;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class AffiliateController extends BaseController
{
    public function __construct(
        private readonly AffiliateRepositoryInterface       $affiliateRepo,
        private readonly AffiliateWalletRepositoryInterface $affiliateWalletRepo,
        private readonly BusinessSettingRepositoryInterface $businessSettingRepo,
    )
    {
    }

    public function index(?Request $request, ?string $type = null): View
    {
        $affiliates = $this->affiliateRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            searchValue: $request['searchValue'] ?? null,
            filters: array_filter(['status' => $request['status'] ?? null]),
            relations: ['wallet'],
            dataLimit: 25,
        );

        return view('admin-views.affiliate.index', [
            'affiliates' => $affiliates,
            'searchValue' => $request['searchValue'] ?? null,
        ]);
    }

    public function updateStatus(Request $request, int $id): RedirectResponse
    {
        $request->validate([
            'status' => 'required|in:approved,suspended,pending',
        ]);

        $affiliate = $this->affiliateRepo->getFirstWhere(params: ['id' => $id]);
        if (!$affiliate) {
            ToastMagic::error(translate('affiliate_not_found'));
            return back();
        }

        if ($request['status'] === 'approved' && !$this->affiliateWalletRepo->getFirstWhere(params: ['affiliate_id' => $id])) {
            $this->affiliateWalletRepo->add([
                'affiliate_id' => $id,
                'total_earning' => 0,
                'pending_withdraw' => 0,
                'withdrawn' => 0,
            ]);
        }

        $this->affiliateRepo->update(id: $id, data: ['status' => $request['status']]);
        ToastMagic::success(translate('affiliate_status_updated_successfully'));
        return back();
    }

    public function settings(): View
    {
        return view('admin-views.affiliate.settings', [
            'affiliateProgramStatus' => getWebConfig(name: 'affiliate_program_status'),
            'affiliateCommissionRate' => getWebConfig(name: 'affiliate_commission_rate'),
        ]);
    }

    public function updateSettings(Request $request): RedirectResponse
    {
        $request->validate([
            'affiliate_commission_rate' => 'required|numeric|min:0|max:100',
        ]);

        $this->businessSettingRepo->updateOrInsert(type: 'affiliate_program_status', value: $request->get('affiliate_program_status', 0));
        $this->businessSettingRepo->updateOrInsert(type: 'affiliate_commission_rate', value: $request['affiliate_commission_rate']);
        clearWebConfigCacheKeys();

        ToastMagic::success(translate('successfully_updated'));
        return back();
    }
}
