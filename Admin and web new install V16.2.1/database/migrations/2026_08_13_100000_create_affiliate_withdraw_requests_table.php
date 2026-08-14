<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Dedicated table rather than reusing withdraw_requests: that table
        // carries a seller/deliveryman-specific withdrawal-method system
        // affiliates don't have, and overloading it further would mean every
        // query there needs yet another actor-column branch.
        Schema::create('affiliate_withdraw_requests', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('affiliate_id');
            $table->decimal('amount', 40, 20)->default(0);
            $table->text('transaction_note')->nullable();
            $table->unsignedTinyInteger('approved')->default(0); // 0=pending, 1=approved, 2=denied
            $table->unsignedBigInteger('admin_id')->nullable();
            $table->timestamps();

            $table->index('affiliate_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('affiliate_withdraw_requests');
    }
};
