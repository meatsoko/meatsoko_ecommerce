<?php

use App\Models\Setting;
use Illuminate\Database\Migrations\Migration;

/**
 * C2B (Paybill/Till) support has been removed in favour of a single M-Pesa
 * STK Push gateway (see MpesaStkController). Its controller, routes, and
 * webhooks are gone; this drops the leftover addon_settings row so it no
 * longer shows up anywhere config is enumerated.
 *
 * NOTE: if this Till/Paybill's Confirmation/Validation URLs are still
 * registered with Safaricom (Daraja portal) for payment/c2b/* or
 * api/payments/c2b/*, those callbacks will now 404 - unregister or point
 * them elsewhere on Safaricom's side if that shortcode still takes direct
 * payments.
 */
return new class extends Migration {
    public function up(): void
    {
        Setting::where('settings_type', 'payment_config')
            ->where('key_name', 'mpesa_c2b')
            ->delete();
    }

    public function down(): void
    {
        // Not restored - see 2026_07_09_000002_seed_mpesa_payment_gateways.php
        // for the original seed shape if C2B is ever reintroduced.
    }
};
