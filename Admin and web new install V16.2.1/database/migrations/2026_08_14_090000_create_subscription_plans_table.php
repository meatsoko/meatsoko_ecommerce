<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Flat, admin-set price + shipping cost — deliberately not computed
        // from the attached products at billing time. This is what lets the
        // billing job skip re-implementing OrderManager's tax/shipping engine.
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->enum('cadence', ['weekly', 'monthly']);
            $table->decimal('price', 40, 20);
            $table->decimal('shipping_cost', 40, 20)->default(0);
            $table->string('image')->nullable();
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_plans');
    }
};
