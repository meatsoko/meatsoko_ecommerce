<?php

namespace App\Http\Controllers\Vendor;

use App\Contracts\Repositories\AdPlacementRepositoryInterface;
use App\Http\Controllers\BaseController;
use App\Library\Payer;
use App\Library\Payment as PaymentInfo;
use App\Library\Receiver;
use App\Models\AdPlacement;
use App\Models\Currency;
use App\Models\Product;
use App\Traits\Payment;
use Devrabiul\ToastMagic\Facades\ToastMagic;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\DB;

class AdvertisingController extends BaseController
{
    use Payment;

    public function __construct(
        private readonly AdPlacementRepositoryInterface $adPlacementRepo,
    )
    {
    }

    public function index(?Request $request = null, ?string $type = null): View
    {
        $sellerId = auth('seller')->id();

        $products = Product::where(['user_id' => $sellerId, 'added_by' => 'seller', 'status' => 1])->get();
        $placements = $this->adPlacementRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            filters: ['seller_id' => $sellerId],
            relations: ['product'],
            dataLimit: 20,
        );
        $activeSlotCount = AdPlacement::active()->count();

        return view('vendor-views.advertising.index', [
            'products' => $products,
            'placements' => $placements,
            'pricePerDay' => (float)(getWebConfig(name: 'ad_placement_price_per_day') ?? 0),
            'maxActiveSlots' => (int)(getWebConfig(name: 'ad_placement_max_active_slots') ?? 0),
            'activeSlotCount' => $activeSlotCount,
            'programEnabled' => getWebConfig(name: 'ad_placement_status') == 1,
        ]);
    }

    /**
     * Checked here, before any money moves, rather than at payment-success —
     * a vendor should never be able to pay for a slot and then be told there
     * isn't one. See AdPlacementRepository::hasActiveOrPendingForProduct()
     * for the per-product half of this same principle.
     */
    public function purchase(Request $request): RedirectResponse|Redirector
    {
        $sellerId = auth('seller')->id();

        if (getWebConfig(name: 'ad_placement_status') != 1) {
            ToastMagic::error(translate('the_sponsored_product_program_is_currently_unavailable'));
            return back();
        }

        $request->validate([
            'product_id' => 'required|integer',
            'days' => 'required|integer|min:1|max:60',
            'payment_method' => 'required|string',
        ]);

        $product = Product::where(['id' => $request['product_id'], 'user_id' => $sellerId, 'added_by' => 'seller', 'status' => 1])->first();
        if (!$product) {
            ToastMagic::error(translate('product_not_found_or_not_yours_to_advertise'));
            return back();
        }

        if ($this->adPlacementRepo->hasActiveOrPendingForProduct($product->id)) {
            ToastMagic::error(translate('this_product_already_has_an_active_or_pending_sponsored_placement'));
            return back();
        }

        $pricePerDay = (float)(getWebConfig(name: 'ad_placement_price_per_day') ?? 0);
        $days = (int)$request['days'];
        $amount = round($pricePerDay * $days, 2);
        if ($amount <= 0) {
            ToastMagic::error(translate('invalid_request'));
            return back();
        }

        $maxActiveSlots = (int)(getWebConfig(name: 'ad_placement_max_active_slots') ?? 0);

        // Locks every active/pending row for the duration of the transaction so
        // two vendors buying concurrently can't both read the same under-cap
        // count and both slip through — pending is counted too, since a slot
        // is reserved the moment a purchase starts, not once payment clears.
        $placement = DB::transaction(function () use ($sellerId, $product, $days, $amount, $maxActiveSlots) {
            $slotCount = AdPlacement::whereIn('status', ['active', 'pending'])
                ->where(function ($query) {
                    $query->where('status', 'pending')->orWhere('end_at', '>', now());
                })
                ->lockForUpdate()
                ->count();

            if ($maxActiveSlots > 0 && $slotCount >= $maxActiveSlots) {
                return null;
            }

            return $this->adPlacementRepo->add([
                'seller_id' => $sellerId,
                'product_id' => $product->id,
                'days' => $days,
                'amount_paid' => $amount,
                'status' => 'pending',
            ]);
        });

        if (!$placement) {
            ToastMagic::error(translate('all_sponsored_slots_are_currently_taken_please_try_again_later'));
            return back();
        }

        $seller = auth('seller')->user();
        $payer = new Payer(
            $seller->f_name . ' ' . $seller->l_name,
            $seller->email,
            $seller->phone,
            ''
        );

        // Ad placements are priced and charged in the platform's default
        // currency only — no multi-currency conversion for this flow, unlike
        // customer checkout. Simpler and sufficient for a first version.
        $currencyCode = Currency::find(getWebConfig(name: 'system_default_currency'))?->code ?? 'USD';

        $paymentInfo = new PaymentInfo(
            success_hook: 'ad_placement_payment_success',
            failure_hook: 'ad_placement_payment_fail',
            currency_code: $currencyCode,
            payment_method: $request['payment_method'],
            payment_platform: 'web',
            payer_id: $sellerId,
            receiver_id: '1',
            additional_data: ['ad_placement_id' => $placement->id],
            payment_amount: $amount,
            external_redirect_link: route('vendor.advertising.index'),
            attribute: 'ad_placement',
            attribute_id: (string)$placement->id,
        );

        $receiverInfo = new Receiver('MeatSoko', 'example.png');

        $redirectLink = Payment::generate_link($payer, $paymentInfo, $receiverInfo);
        return redirect($redirectLink);
    }
}
