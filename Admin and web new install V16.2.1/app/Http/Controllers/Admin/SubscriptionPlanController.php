<?php

namespace App\Http\Controllers\Admin;

use App\Contracts\Repositories\BusinessSettingRepositoryInterface;
use App\Contracts\Repositories\SubscriptionPlanProductRepositoryInterface;
use App\Contracts\Repositories\SubscriptionPlanRepositoryInterface;
use App\Http\Controllers\BaseController;
use App\Http\Requests\Admin\SubscriptionPlanAddRequest;
use App\Models\Product;
use App\Services\SubscriptionPlanService;
use Devrabiul\ToastMagic\Facades\ToastMagic;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class SubscriptionPlanController extends BaseController
{
    public function __construct(
        private readonly SubscriptionPlanRepositoryInterface        $planRepo,
        private readonly SubscriptionPlanProductRepositoryInterface $planProductRepo,
        private readonly BusinessSettingRepositoryInterface         $businessSettingRepo,
    )
    {
    }

    public function index(?Request $request): View
    {
        $plans = $this->planRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            searchValue: $request['searchValue'] ?? null,
            relations: ['products', 'subscriptions'],
            dataLimit: getWebConfig('pagination_limit') ?? 25,
        );

        return view('admin-views.subscription-plan.index', ['plans' => $plans, 'searchValue' => $request['searchValue'] ?? null]);
    }

    public function create(): View
    {
        return view('admin-views.subscription-plan.create');
    }

    public function store(SubscriptionPlanAddRequest $request, SubscriptionPlanService $service): RedirectResponse
    {
        $plan = $this->planRepo->add($service->getAddData($request));
        ToastMagic::success(translate('subscription_plan_added_successfully_now_add_its_box_products'));
        return redirect()->route('admin.subscription-plan.products', $plan->id);
    }

    public function edit(int $id): View|RedirectResponse
    {
        $plan = $this->planRepo->getFirstWhere(params: ['id' => $id]);
        if (!$plan) {
            ToastMagic::error(translate('subscription_plan_not_found'));
            return redirect()->route('admin.subscription-plan.list');
        }
        return view('admin-views.subscription-plan.create', compact('plan'));
    }

    public function update(SubscriptionPlanAddRequest $request, int $id, SubscriptionPlanService $service): RedirectResponse
    {
        $plan = $this->planRepo->getFirstWhere(params: ['id' => $id]);
        if (!$plan) {
            ToastMagic::error(translate('subscription_plan_not_found'));
            return redirect()->route('admin.subscription-plan.list');
        }
        $this->planRepo->update(id: (string)$id, data: $service->getUpdateData($request, $plan));
        ToastMagic::success(translate('subscription_plan_updated_successfully'));
        return redirect()->route('admin.subscription-plan.list');
    }

    public function updateStatus(Request $request, int $id): RedirectResponse
    {
        $request->validate(['status' => 'required|in:active,inactive']);
        $this->planRepo->update(id: (string)$id, data: ['status' => $request['status']]);
        ToastMagic::success(translate('subscription_plan_status_updated_successfully'));
        return back();
    }

    public function products(int $id, ?Request $request): View|RedirectResponse
    {
        $plan = $this->planRepo->getFirstWhere(params: ['id' => $id], relations: ['products.product']);
        if (!$plan) {
            ToastMagic::error(translate('subscription_plan_not_found'));
            return redirect()->route('admin.subscription-plan.list');
        }

        $selectedProductIds = $plan->products->pluck('product_id')->toArray();

        // v1 scope: box contents are restricted to admin/in-house products
        // only — see SubscriptionOrderBuilder's docblock for why (avoids
        // multi-vendor order splitting entirely). Already-attached products
        // are excluded here — they're managed in the "box contents" table
        // instead, so a page change/search here can never wipe them (each
        // action below only ever touches the specific rows it submits).
        $products = Product::active()->where('added_by', 'admin')
            ->whereNotIn('id', $selectedProductIds)
            ->when($request['searchValue'] ?? null, function ($query) use ($request) {
                $query->where('name', 'like', "%{$request['searchValue']}%");
            })
            ->orderBy('id', 'desc')
            ->paginate(getWebConfig('pagination_limit') ?? 25)
            ->appends($request->all());

        return view('admin-views.subscription-plan.products', compact('plan', 'products'));
    }

    public function addProducts(Request $request, int $id): RedirectResponse
    {
        $plan = $this->planRepo->getFirstWhere(params: ['id' => $id]);
        if (!$plan) {
            ToastMagic::error(translate('subscription_plan_not_found'));
            return redirect()->route('admin.subscription-plan.list');
        }

        $productIds = $request['product_id'] ?? [];
        $quantities = $request['quantity'] ?? [];
        foreach ($productIds as $productId) {
            if ($this->planProductRepo->getFirstWhere(params: ['subscription_plan_id' => $id, 'product_id' => $productId])) {
                continue;
            }
            $qty = max(1, (int)($quantities[$productId] ?? 1));
            $this->planProductRepo->add([
                'subscription_plan_id' => $id,
                'product_id' => $productId,
                'quantity' => $qty,
            ]);
        }

        ToastMagic::success(translate('box_products_added_successfully'));
        return redirect()->route('admin.subscription-plan.products', $id);
    }

    public function updateProductQuantities(Request $request, int $id): RedirectResponse
    {
        $quantities = $request['quantity'] ?? [];
        foreach ($quantities as $productId => $qty) {
            $planProduct = $this->planProductRepo->getFirstWhere(params: ['subscription_plan_id' => $id, 'product_id' => $productId]);
            if ($planProduct) {
                $this->planProductRepo->update(id: (string)$planProduct->id, data: ['quantity' => max(1, (int)$qty)]);
            }
        }

        ToastMagic::success(translate('quantities_updated_successfully'));
        return redirect()->route('admin.subscription-plan.products', $id);
    }

    public function removeProduct(int $id, int $productId): RedirectResponse
    {
        $this->planProductRepo->delete(params: ['subscription_plan_id' => $id, 'product_id' => $productId]);
        ToastMagic::success(translate('product_removed_from_box_successfully'));
        return redirect()->route('admin.subscription-plan.products', $id);
    }

    public function settings(): View
    {
        return view('admin-views.subscription-plan.settings', [
            'subscriptionProgramStatus' => getWebConfig(name: 'subscription_program_status'),
        ]);
    }

    public function updateSettings(Request $request): RedirectResponse
    {
        $this->businessSettingRepo->updateOrInsert(type: 'subscription_program_status', value: $request->get('subscription_program_status', 0));
        clearWebConfigCacheKeys();
        ToastMagic::success(translate('successfully_updated'));
        return back();
    }
}
