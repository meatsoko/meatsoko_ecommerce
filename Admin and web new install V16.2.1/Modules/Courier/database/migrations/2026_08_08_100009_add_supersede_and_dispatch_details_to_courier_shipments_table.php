<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('courier_shipments', function (Blueprint $table) {
            $table->json('dispatch_details')->nullable()->after('payload');
            $table->timestamp('superseded_at')->nullable()->index()->after('dispatch_details');
        });
    }

    public function down(): void
    {
        Schema::table('courier_shipments', function (Blueprint $table) {
            $table->dropColumn(['dispatch_details', 'superseded_at']);
        });
    }
};
