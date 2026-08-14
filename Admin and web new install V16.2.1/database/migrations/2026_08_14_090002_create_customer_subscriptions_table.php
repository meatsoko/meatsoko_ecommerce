<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('customer_subscriptions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id');
            $table->unsignedBigInteger('subscription_plan_id');
            $table->enum('payment_method', ['wallet', 'mpesa']);
            $table->string('phone')->nullable();
            $table->unsignedBigInteger('shipping_address_id');
            $table->enum('status', ['active', 'paused', 'cancelled'])->default('active');
            $table->date('next_billing_date');
            // Consecutive failures since the last successful charge — reset to 0
            // on success, and at 2 the subscription is auto-paused (see
            // ProcessCustomerSubscriptions).
            $table->unsignedTinyInteger('failed_attempts')->default(0);
            $table->dateTime('last_charged_at')->nullable();
            $table->timestamps();

            $table->index('customer_id');
            $table->index(['status', 'next_billing_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_subscriptions');
    }
};
