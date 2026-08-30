<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('courier_shipments', function (Blueprint $table) {
            $table->dropUnique('courier_shipments_provider_consignment_id_unique');
        });

        Schema::table('courier_shipments', function (Blueprint $table) {
            $table->string('active_consignment_key', 191)->nullable()->virtualAs(
                "case when `superseded_at` is null and `consignment_id` is not null " .
                "then concat(`owner_type`, '-', `owner_id`, '-', `provider`, '-', `consignment_id`, '-', coalesce(`host_order_reference`, '')) " .
                "else null end"
            );
        });

        Schema::table('courier_shipments', function (Blueprint $table) {
            $table->unique('active_consignment_key', 'courier_shipments_active_consignment_unique');
        });
    }

    public function down(): void
    {
        Schema::table('courier_shipments', function (Blueprint $table) {
            $table->dropUnique('courier_shipments_active_consignment_unique');
            $table->dropColumn('active_consignment_key');
        });

        Schema::table('courier_shipments', function (Blueprint $table) {
            $table->unique(['provider', 'consignment_id']);
        });
    }
};
