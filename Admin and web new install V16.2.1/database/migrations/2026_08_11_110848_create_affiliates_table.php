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
        Schema::create('affiliates', function (Blueprint $table) {
            $table->id();
            $table->string('f_name', 30);
            $table->string('l_name', 30)->nullable();
            $table->string('country_code', 10)->nullable();
            $table->string('phone', 25)->nullable();
            $table->string('email', 80)->unique();
            $table->string('password', 80)->nullable();
            $table->string('image', 60)->default('def.png');
            $table->string('affiliate_code', 20)->unique();
            // pending: awaiting admin approval, approved: can earn + withdraw, suspended: blocked (e.g. after abuse)
            $table->string('status', 15)->default('pending');
            $table->text('auth_token')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('affiliates');
    }
};
