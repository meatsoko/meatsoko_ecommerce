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
        Schema::create('ad_placements', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('seller_id');
            $table->unsignedBigInteger('product_id');
            $table->unsignedInteger('days');
            $table->decimal('amount_paid', 40, 20)->default(0);
            $table->timestamp('start_at')->nullable();
            $table->timestamp('end_at')->nullable();
            // pending: payment not yet completed, active: currently shown as
            // sponsored, expired: end_at has passed (set by the scheduled
            // ads:expire-placements command, never computed on the fly, so
            // "what's sponsored right now" is always a single indexed lookup).
            $table->string('status', 15)->default('pending');
            $table->uuid('payment_request_id')->nullable();
            $table->timestamps();

            $table->index(['status', 'end_at']);
            $table->index('product_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ad_placements');
    }
};
