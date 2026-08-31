<?php

use App\Models\Setting;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration {
    public function up(): void
    {
        if (!Setting::where(['key_name' => 'jenga_equity', 'settings_type' => 'payment_config'])->exists()) {
            $values = [
                'gateway' => 'jenga_equity',
                'mode' => 'test',
                'status' => '0',
                'api_key' => null,
                'merchant_code' => null,
                'consumer_secret' => null,
                'account_number' => null,
                'merchant_name' => null,
                'country_code' => null,
                'private_key' => null,
            ];
            Setting::create([
                'key_name' => 'jenga_equity',
                'live_values' => $values,
                'test_values' => $values,
                'settings_type' => 'payment_config',
                'mode' => 'test',
                'is_active' => 0,
                'additional_data' => json_encode(['gateway_title' => 'Equity Bank (Equitel Push)', 'gateway_image' => null]),
            ]);
        }
    }

    public function down(): void
    {
        Setting::where('settings_type', 'payment_config')
            ->where('key_name', 'jenga_equity')
            ->delete();
    }
};
