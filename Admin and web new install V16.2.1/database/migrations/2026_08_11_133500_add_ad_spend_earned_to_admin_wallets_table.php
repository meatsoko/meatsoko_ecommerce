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
            $table->decimal('ad_spend_earned', 40, 20)->default(0)->after('service_fee_earned');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('admin_wallets', function (Blueprint $table) {
            $table->dropColumn('ad_spend_earned');
        });
    }
};
