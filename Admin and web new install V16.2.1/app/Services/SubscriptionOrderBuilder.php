<?php

namespace App\Services;

use App\Models\CustomerSubscription;
use App\Models\Order;
use App\Models\OrderDetail;
use App\Models\OrderStatusHistory;
use App\Models\Product;
use App\Utils\OrderManager;
use Illuminate\Support\Facades\DB;

/**
 * Builds a real Order + OrderDetail rows for a subscription's billing cycle,
 * deliberately WITHOUT touching the shared `carts` table or calling
 * OrderManager::generateOrder(). That method checks out a customer's entire
 * current cart (not a scoped subset), so driving it from a background job
 * would risk silently sweeping in whatever unrelated items the customer
 * already has sitting in their cart. See the "Customer Subscription Boxes"
 * plan for the full reasoning.
 *
 * Because subscription plans have an admin-set flat price and shipping cost
 * (not a computed cart total), this deliberately does not replicate
 * OrderManager's tax/shipping/commission engine — order_amount is just the
 * plan price, and each OrderDetail's price is a current-price snapshot for
 * record-keeping (matching the only existing "reprice at fulfillment time"
 * precedent in this codebase, OrderManager::generateOrderAgain()).
 *
 * Scope: subscription plan products must all be admin/in-house products
 * (enforced at plan-creation time) — this avoids multi-vendor order
 * splitting entirely, so every order this builds has seller_id = 0,
 * seller_is = 'admin'.
 */
class SubscriptionOrderBuilder
{
    public function build(CustomerSubscription $subscription): Order
    {
        return DB::transaction(fn () => $this->buildInsideTransaction($subscription));
    }

    private function buildInsideTransaction(CustomerSubscription $subscription): Order
    {
        $plan = $subscription->plan;
        $orderId = OrderManager::generateNewOrderID();
        $orderGroupId = $subscription->customer_id . '-sub-' . time();

        $order = Order::create([
            'id' => $orderId,
            'verification_code' => rand(100000, 999999),
            'customer_id' => $subscription->customer_id,
            'is_guest' => 0,
            'customer_type' => 'customer',
            'seller_id' => 0,
            'seller_is' => 'admin',
            'payment_status' => $subscription->payment_method === 'wallet' ? 'paid' : 'unpaid',
            'order_status' => $subscription->payment_method === 'wallet' ? 'confirmed' : 'pending',
            'payment_method' => $subscription->payment_method === 'wallet' ? 'pay_by_wallet' : 'mpesa_stk',
            'order_group_id' => $orderGroupId,
            'discount_amount' => 0,
            'discount_type' => 'percent',
            'order_amount' => $plan->price,
            'init_order_amount' => $plan->price,
            'total_tax_amount' => 0,
            'tax_type' => 'excluded',
            'tax_model' => 'exclude',
            'admin_commission' => 0,
            'shipping_address' => $subscription->shipping_address_id,
            'shipping_address_data' => optional($subscription->shippingAddress)->toArray(),
            'shipping_responsibility' => getWebConfig(name: 'shipping_method'),
            'shipping_cost' => $plan->shipping_cost,
            'service_fee' => 0,
            'receiving_method' => 'delivery',
            'order_note' => 'Subscription billing: ' . $plan->title,
        ]);

        foreach ($plan->products as $planProduct) {
            $product = Product::find($planProduct->product_id);
            if (!$product) {
                continue;
            }

            OrderDetail::create([
                'order_id' => $order->id,
                'product_id' => $product->id,
                'seller_id' => 0,
                'product_details' => json_encode($product->toArray()),
                'qty' => $planProduct->quantity,
                'price' => $product->unit_price,
                'discount' => 0,
                'discount_type' => 'discount_on_product',
                'variant' => null,
                'variation' => null,
                'delivery_status' => 'pending',
                'payment_status' => $subscription->payment_method === 'wallet' ? 'paid' : 'unpaid',
                'tax' => 0,
                'tax_model' => 'exclude',
            ]);

            // Same stock-decrement statement OrderManager::addOrderDetailsData()
            // uses for physical products — deliberately not routed through that
            // method since it expects a cart-shaped input.
            Product::where('id', $product->id)->update([
                'current_stock' => max(0, $product->current_stock - $planProduct->quantity),
            ]);
        }

        OrderStatusHistory::create([
            'order_id' => $order->id,
            'user_id' => $subscription->customer_id,
            'user_type' => 'customer',
            'status' => $order->order_status,
        ]);

        return $order;
    }
}
