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
        Schema::table('chattings', function (Blueprint $table) {
            $table->boolean('flagged')->after('status')->default(0);
            $table->string('flag_reason', 100)->after('flagged')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('chattings', function (Blueprint $table) {
            $table->dropColumn('flag_reason');
            $table->dropColumn('flagged');
        });
    }
};
