<?php

namespace App\Http\Controllers\Admin;

use App\Contracts\Repositories\CustomerSubscriptionRepositoryInterface;
use App\Contracts\Repositories\SubscriptionChargeRepositoryInterface;
use App\Http\Controllers\BaseController;
use App\Services\SubscriptionBillingService;
use Devrabiul\ToastMagic\Facades\ToastMagic;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class CustomerSubscriptionController extends BaseController
{
    public function __construct(
        private readonly CustomerSubscriptionRepositoryInterface $subscriptionRepo,
        private readonly SubscriptionChargeRepositoryInterface   $chargeRepo,
    )
    {
    }

    public function index(?Request $request, ?string $type = null): View
    {
        $subscriptions = $this->subscriptionRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            searchValue: $request['searchValue'] ?? null,
            filters: array_filter(['status' => $request['status'] ?? null]),
            relations: ['customer', 'plan'],
            dataLimit: getWebConfig('pagination_limit') ?? 25,
        );

        return view('admin-views.subscription-plan.subscribers', ['subscriptions' => $subscriptions, 'searchValue' => $request['searchValue'] ?? null]);
    }

    public function view(int $id): View|RedirectResponse
    {
        $subscription = $this->subscriptionRepo->getFirstWhere(params: ['id' => $id], relations: ['customer', 'plan.products.product', 'shippingAddress']);
        if (!$subscription) {
            ToastMagic::error(translate('subscription_not_found'));
            return redirect()->route('admin.subscription.subscribers');
        }

        $charges = $this->chargeRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            filters: ['customer_subscription_id' => $id],
            dataLimit: getWebConfig('pagination_limit') ?? 25,
        );

        return view('admin-views.subscription-plan.subscriber-view', compact('subscription', 'charges'));
    }

    public function updateStatus(Request $request, int $id): RedirectResponse
    {
        $request->validate(['status' => 'required|in:active,paused,cancelled']);
        $this->subscriptionRepo->update(id: (string)$id, data: ['status' => $request['status']]);
        ToastMagic::success(translate('subscription_status_updated_successfully'));
        return back();
    }

    /**
     * Manually triggers one billing attempt right now — for support cases
     * ("customer says they topped up their wallet, don't want them to wait
     * for tomorrow's scheduled run") rather than a routine part of the
     * billing cycle. Reuses the exact same SubscriptionBillingService the
     * subscriptions:bill-due command calls, so this is a thin trigger, not
     * a second implementation of the charge logic.
     */
    public function billNow(int $id, SubscriptionBillingService $billingService): RedirectResponse
    {
        $subscription = $this->subscriptionRepo->getFirstWhere(params: ['id' => $id], relations: ['plan']);
        if (!$subscription) {
            ToastMagic::error(translate('subscription_not_found'));
            return back();
        }
        if ($subscription->status === 'cancelled') {
            ToastMagic::error(translate('cannot_bill_a_cancelled_subscription'));
            return back();
        }

        $billingService->chargeSubscription($subscription);

        $subscription->refresh();
        $latestCharge = $subscription->charges()->latest('id')->first();
        if ($latestCharge?->status === 'success') {
            ToastMagic::success(translate('charge_succeeded'));
        } elseif ($latestCharge?->status === 'pending') {
            ToastMagic::success(translate('mpesa_push_sent_awaiting_customer_approval'));
        } else {
            ToastMagic::error(translate('charge_failed') . ': ' . ($latestCharge?->failure_reason ?? ''));
        }

        return back();
    }
}
