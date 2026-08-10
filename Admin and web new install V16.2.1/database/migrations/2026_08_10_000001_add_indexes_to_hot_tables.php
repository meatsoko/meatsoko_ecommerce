<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {

    /**
     * table => [ [columns, indexName], ... ]
     */
    private function indexMap(): array
    {
        return [
            'carts' => [
                [['customer_id'], 'idx_carts_customer_id'],
                [['cart_group_id'], 'idx_carts_cart_group_id'],
                [['product_id'], 'idx_carts_product_id'],
                [['seller_id'], 'idx_carts_seller_id'],
            ],
            'wishlists' => [
                [['customer_id', 'product_id'], 'idx_wishlists_customer_product'],
            ],
            'reviews' => [
                [['product_id', 'status'], 'idx_reviews_product_status'],
                [['customer_id'], 'idx_reviews_customer_id'],
                [['order_id'], 'idx_reviews_order_id'],
            ],
            'notifications' => [
                [['sent_to', 'status'], 'idx_notifications_sent_to_status'],
                [['sent_by'], 'idx_notifications_sent_by'],
            ],
            'order_status_histories' => [
                [['order_id', 'status'], 'idx_order_status_histories_order_status'],
            ],
            'delivery_histories' => [
                [['order_id'], 'idx_delivery_histories_order_id'],
                [['deliveryman_id'], 'idx_delivery_histories_deliveryman_id'],
            ],
            'shop_followers' => [
                [['shop_id', 'user_id'], 'idx_shop_followers_shop_user'],
            ],
            'chattings' => [
                [['user_id', 'seller_id'], 'idx_chattings_user_seller'],
                [['admin_id'], 'idx_chattings_admin_id'],
                [['delivery_man_id'], 'idx_chattings_delivery_man_id'],
                [['shop_id'], 'idx_chattings_shop_id'],
            ],
            'product_stocks' => [
                [['product_id'], 'idx_product_stocks_product_id'],
            ],
            'flash_deal_products' => [
                [['flash_deal_id'], 'idx_flash_deal_products_flash_deal_id'],
                [['product_id'], 'idx_flash_deal_products_product_id'],
            ],
            'shipping_addresses' => [
                [['customer_id'], 'idx_shipping_addresses_customer_id'],
            ],
            'billing_addresses' => [
                [['customer_id'], 'idx_billing_addresses_customer_id'],
            ],
            'deal_of_the_days' => [
                [['product_id', 'status'], 'idx_deal_of_the_days_product_status'],
            ],
            'support_ticket_convs' => [
                [['support_ticket_id'], 'idx_support_ticket_convs_ticket_id'],
            ],
            'recent_searches' => [
                [['user_id'], 'idx_recent_searches_user_id'],
            ],
            'product_compares' => [
                [['user_id', 'product_id'], 'idx_product_compares_user_product'],
            ],
            'restock_products' => [
                [['product_id'], 'idx_restock_products_product_id'],
            ],
            'loyalty_point_transactions' => [
                [['user_id'], 'idx_loyalty_point_transactions_user_id'],
            ],
        ];
    }

    private function getExistingIndexes(string $table): array
    {
        return collect(DB::select("SHOW INDEX FROM `{$table}`"))
            ->pluck('Key_name')
            ->unique()
            ->toArray();
    }

    public function up(): void
    {
        foreach ($this->indexMap() as $table => $indexes) {
            if (!Schema::hasTable($table)) {
                continue;
            }

            $existing = $this->getExistingIndexes($table);

            Schema::table($table, function (Blueprint $blueprint) use ($indexes, $existing) {
                foreach ($indexes as [$columns, $name]) {
                    if (!in_array($name, $existing)) {
                        $blueprint->index($columns, $name);
                    }
                }
            });
        }
    }

    public function down(): void
    {
        foreach ($this->indexMap() as $table => $indexes) {
            if (!Schema::hasTable($table)) {
                continue;
            }

            $existing = $this->getExistingIndexes($table);

            Schema::table($table, function (Blueprint $blueprint) use ($indexes, $existing) {
                foreach ($indexes as [$columns, $name]) {
                    if (in_array($name, $existing)) {
                        $blueprint->dropIndex($name);
                    }
                }
            });
        }
    }
};
