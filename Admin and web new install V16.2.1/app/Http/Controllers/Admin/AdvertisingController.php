<?php

namespace App\Http\Controllers\Admin;

use App\Contracts\Repositories\AdPlacementRepositoryInterface;
use App\Contracts\Repositories\BusinessSettingRepositoryInterface;
use App\Http\Controllers\BaseController;
use Devrabiul\ToastMagic\Facades\ToastMagic;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class AdvertisingController extends BaseController
{
    public function __construct(
        private readonly AdPlacementRepositoryInterface     $adPlacementRepo,
        private readonly BusinessSettingRepositoryInterface $businessSettingRepo,
    )
    {
    }

    public function index(Request $request): View
    {
        $placements = $this->adPlacementRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            filters: array_filter(['status' => $request['status'] ?? null]),
            relations: ['seller', 'product'],
            dataLimit: 25,
        );

        return view('admin-views.advertising.index', ['placements' => $placements]);
    }

    public function settings(): View
    {
        return view('admin-views.advertising.settings', [
            'adPlacementStatus' => getWebConfig(name: 'ad_placement_status'),
            'adPlacementPricePerDay' => getWebConfig(name: 'ad_placement_price_per_day'),
            'adPlacementMaxActiveSlots' => getWebConfig(name: 'ad_placement_max_active_slots'),
        ]);
    }

    public function updateSettings(Request $request): RedirectResponse
    {
        $request->validate([
            'ad_placement_price_per_day' => 'required|numeric|min:0',
            'ad_placement_max_active_slots' => 'required|integer|min:1|max:50',
        ]);

        $this->businessSettingRepo->updateOrInsert(type: 'ad_placement_status', value: $request->get('ad_placement_status', 0));
        $this->businessSettingRepo->updateOrInsert(type: 'ad_placement_price_per_day', value: $request['ad_placement_price_per_day']);
        $this->businessSettingRepo->updateOrInsert(type: 'ad_placement_max_active_slots', value: $request['ad_placement_max_active_slots']);
        clearWebConfigCacheKeys();

        ToastMagic::success(translate('successfully_updated'));
        return back();
    }
}
