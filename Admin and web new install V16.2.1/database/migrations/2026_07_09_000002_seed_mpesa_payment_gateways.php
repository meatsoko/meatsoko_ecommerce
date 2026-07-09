<?php

use App\Models\Setting;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration {
    public function up(): void
    {
        if (!Setting::where(['key_name' => 'mpesa_stk', 'settings_type' => 'payment_config'])->exists()) {
            $values = [
                'gateway' => 'mpesa_stk',
                'mode' => 'test',
                'status' => '0',
                'consumer_key' => null,
                'consumer_secret' => null,
                'shortcode' => null,
                'passkey' => null,
            ];
            Setting::create([
                'key_name' => 'mpesa_stk',
                'live_values' => $values,
                'test_values' => $values,
                'settings_type' => 'payment_config',
                'mode' => 'test',
                'is_active' => 0,
                'additional_data' => json_encode(['gateway_title' => 'M-Pesa (STK Push)', 'gateway_image' => null]),
            ]);
        }

        if (!Setting::where(['key_name' => 'mpesa_c2b', 'settings_type' => 'payment_config'])->exists()) {
            $values = [
                'gateway' => 'mpesa_c2b',
                'mode' => 'test',
                'status' => '0',
                'consumer_key' => null,
                'consumer_secret' => null,
                'shortcode' => null,
                'initiator_name' => null,
                'initiator_password' => null,
            ];
            Setting::create([
                'key_name' => 'mpesa_c2b',
                'live_values' => $values,
                'test_values' => $values,
                'settings_type' => 'payment_config',
                'mode' => 'test',
                'is_active' => 0,
                'additional_data' => json_encode(['gateway_title' => 'M-Pesa (Paybill/Till)', 'gateway_image' => null]),
            ]);
        }
    }

    public function down(): void
    {
        Setting::where('settings_type', 'payment_config')
            ->whereIn('key_name', ['mpesa_stk', 'mpesa_c2b'])
            ->delete();
    }
};
