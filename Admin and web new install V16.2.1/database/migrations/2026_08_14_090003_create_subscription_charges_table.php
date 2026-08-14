<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // One row per billing attempt — the audit trail for a subscription's
        // charge history, independent of whether it ever produced an order.
        Schema::create('subscription_charges', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_subscription_id');
            $table->unsignedBigInteger('order_id')->nullable();
            $table->decimal('amount', 40, 20);
            $table->enum('payment_method', ['wallet', 'mpesa']);
            $table->enum('status', ['pending', 'success', 'failed'])->default('pending');
            $table->string('failure_reason')->nullable();
            $table->dateTime('attempted_at');
            $table->timestamps();

            $table->index('customer_subscription_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_charges');
    }
};
