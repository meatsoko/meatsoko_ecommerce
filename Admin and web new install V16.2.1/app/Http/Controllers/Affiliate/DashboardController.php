<?php

namespace App\Http\Controllers\Affiliate;

use App\Contracts\Repositories\AffiliateCommissionRepositoryInterface;
use App\Contracts\Repositories\AffiliateWalletRepositoryInterface;
use App\Http\Controllers\Controller;
use Illuminate\Contracts\View\View;

class DashboardController extends Controller
{
    public function __construct(
        private readonly AffiliateWalletRepositoryInterface     $affiliateWalletRepo,
        private readonly AffiliateCommissionRepositoryInterface $affiliateCommissionRepo,
    )
    {
        $this->middleware('auth:affiliate');
    }

    public function index(): View
    {
        $affiliate = auth('affiliate')->user();
        $wallet = $this->affiliateWalletRepo->getFirstWhere(params: ['affiliate_id' => $affiliate->id]);
        $commissions = $this->affiliateCommissionRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            filters: ['affiliate_id' => $affiliate->id],
            relations: ['order'],
            dataLimit: 15,
        );
        $commissionRate = (float)(getWebConfig(name: 'affiliate_commission_rate') ?? 0);
        $affiliateLink = url('/ref/' . $affiliate->affiliate_code);

        return view('affiliate-views.dashboard.index', compact('affiliate', 'wallet', 'commissions', 'commissionRate', 'affiliateLink'));
    }
}
