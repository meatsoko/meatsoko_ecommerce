<?php

namespace App\Http\Controllers\Customer;

use App\Contracts\Repositories\CustomerSubscriptionRepositoryInterface;
use App\Contracts\Repositories\SubscriptionChargeRepositoryInterface;
use App\Contracts\Repositories\SubscriptionPlanRepositoryInterface;
use App\Http\Controllers\Controller;
use App\Models\ShippingAddress;
use Devrabiul\ToastMagic\Facades\ToastMagic;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    public function __construct(
        private readonly SubscriptionPlanRepositoryInterface      $planRepo,
        private readonly CustomerSubscriptionRepositoryInterface  $subscriptionRepo,
        private readonly SubscriptionChargeRepositoryInterface    $chargeRepo,
    )
    {
        $this->middleware('customer')->except(['plans']);
    }

    public function plans(): View
    {
        $plans = $this->planRepo->getListWhere(
            filters: ['status' => 'active'],
            relations: ['products.product'],
            dataLimit: 'all',
        );
        $addresses = auth('customer')->check()
            ? ShippingAddress::where(['customer_id' => auth('customer')->id(), 'is_guest' => 0])->get()
            : collect();

        return view('web-views.subscription.plans', compact('plans', 'addresses'));
    }

    public function subscribe(Request $request, int $planId): RedirectResponse
    {
        $plan = $this->planRepo->getFirstWhere(params: ['id' => $planId, 'status' => 'active']);
        if (!$plan) {
            ToastMagic::error(translate('subscription_plan_not_found'));
            return back();
        }

        $request->validate([
            'payment_method' => 'required|in:wallet,mpesa',
            'phone' => 'required_if:payment_method,mpesa|nullable|string',
            'shipping_address_id' => 'required|exists:shipping_addresses,id',
        ]);

        $this->subscriptionRepo->add([
            'customer_id' => auth('customer')->id(),
            'subscription_plan_id' => $planId,
            'payment_method' => $request['payment_method'],
            'phone' => $request['phone'] ?? null,
            'shipping_address_id' => $request['shipping_address_id'],
            'status' => 'active',
            // First charge is picked up by the next subscriptions:bill-due
            // run rather than charged synchronously from this request.
            'next_billing_date' => now()->toDateString(),
        ]);

        ToastMagic::success(translate('subscribed_successfully_your_first_charge_will_be_processed_shortly'));
        return redirect()->route('customer.subscriptions.index');
    }

    public function index(): View
    {
        $subscriptions = $this->subscriptionRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            filters: ['customer_id' => auth('customer')->id()],
            relations: ['plan'],
            dataLimit: 'all',
        );

        return view('web-views.subscription.my-subscriptions', compact('subscriptions'));
    }

    public function history(int $id): View|RedirectResponse
    {
        $subscription = $this->subscriptionRepo->getFirstWhere(
            params: ['id' => $id, 'customer_id' => auth('customer')->id()],
            relations: ['plan.products.product'],
        );
        if (!$subscription) {
            ToastMagic::error(translate('subscription_not_found'));
            return redirect()->route('customer.subscriptions.index');
        }

        $charges = $this->chargeRepo->getListWhere(
            orderBy: ['id' => 'DESC'],
            filters: ['customer_subscription_id' => $id],
            dataLimit: getWebConfig('pagination_limit') ?? 25,
        );

        return view('web-views.subscription.subscription-history', compact('subscription', 'charges'));
    }

    public function pause(int $id): RedirectResponse
    {
        return $this->setStatus($id, 'paused', 'subscription_paused_successfully');
    }

    public function resume(int $id): RedirectResponse
    {
        $subscription = $this->subscriptionRepo->getFirstWhere(params: ['id' => $id, 'customer_id' => auth('customer')->id()]);
        if ($subscription) {
            // Resuming after a manual pause (or an auto-pause following
            // repeated failures) resets the failure counter and gives the
            // subscription a fresh next billing date rather than
            // immediately re-attempting a charge that may have failed for a
            // reason the customer hasn't necessarily fixed yet.
            $this->subscriptionRepo->update(id: (string)$id, data: [
                'status' => 'active',
                'failed_attempts' => 0,
                'next_billing_date' => now()->toDateString(),
            ]);
            ToastMagic::success(translate('subscription_resumed_successfully'));
        }
        return back();
    }

    public function cancel(int $id): RedirectResponse
    {
        return $this->setStatus($id, 'cancelled', 'subscription_cancelled_successfully');
    }

    private function setStatus(int $id, string $status, string $message): RedirectResponse
    {
        $subscription = $this->subscriptionRepo->getFirstWhere(params: ['id' => $id, 'customer_id' => auth('customer')->id()]);
        if (!$subscription) {
            ToastMagic::error(translate('subscription_not_found'));
            return back();
        }
        $this->subscriptionRepo->update(id: (string)$id, data: ['status' => $status]);
        ToastMagic::success(translate($message));
        return back();
    }
}
