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
        Schema::table('admin_wallets', function (Blueprint $table) {
            $table->decimal('service_fee_earned', 40, 20)->default(0)->after('delivery_charge_earned');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('admin_wallets', function (Blueprint $table) {
            $table->dropColumn('service_fee_earned');
        });
    }
};
