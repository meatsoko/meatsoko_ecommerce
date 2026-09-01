<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('coupons', function (Blueprint $table) {
            $table->index('code');
            $table->index(['seller_id', 'status', 'expire_date']);
        });

        Schema::table('categories', function (Blueprint $table) {
            $table->index('parent_id');
            $table->index('slug');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->index('phone');
            $table->index('referred_by');
        });

        Schema::table('addon_settings', function (Blueprint $table) {
            $table->index('key_name');
        });
    }

    public function down(): void
    {
        Schema::table('coupons', function (Blueprint $table) {
            $table->dropIndex(['code']);
            $table->dropIndex(['seller_id', 'status', 'expire_date']);
        });

        Schema::table('categories', function (Blueprint $table) {
            $table->dropIndex(['parent_id']);
            $table->dropIndex(['slug']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['phone']);
            $table->dropIndex(['referred_by']);
        });

        Schema::table('addon_settings', function (Blueprint $table) {
            $table->dropIndex(['key_name']);
        });
    }
};
