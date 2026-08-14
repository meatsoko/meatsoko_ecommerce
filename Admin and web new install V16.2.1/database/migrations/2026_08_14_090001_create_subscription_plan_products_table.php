<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Mirrors flash_deal_products — one row per box item, quantity instead
        // of a discount column since this is a fixed recurring box, not a sale.
        Schema::create('subscription_plan_products', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('subscription_plan_id');
            $table->unsignedBigInteger('product_id');
            $table->unsignedInteger('quantity')->default(1);
            $table->timestamps();

            $table->index('subscription_plan_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_plan_products');
    }
};
