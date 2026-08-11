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
        // One row per commissioned order — credited once, when the order is
        // marked delivered (never on placement), so canceled/failed/returned
        // orders never pay out. commission_rate is snapshotted per row so a
        // later admin rate change doesn't rewrite historical earnings.
        Schema::create('affiliate_commissions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('affiliate_id');
            $table->unsignedBigInteger('order_id')->unique();
            $table->decimal('order_amount', 40, 20);
            $table->decimal('commission_rate', 5, 2);
            $table->decimal('amount', 40, 20);
            $table->timestamps();

            $table->index('affiliate_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('affiliate_commissions');
    }
};
