<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;

/**
 * The Setting model's live_values/test_values casts were changed from plain
 * 'array' to 'encrypted:array' so gateway credentials (M-Pesa, Stripe,
 * PayPal, etc.) aren't stored as readable JSON. Existing rows are still
 * plain JSON on disk, so they need one direct re-encryption pass here -
 * going through Eloquent's save() would try to decrypt the (not yet
 * encrypted) original value for dirty-checking and throw.
 */
return new class extends Migration {
    public function up(): void
    {
        $rows = DB::table('addon_settings')->select('id', 'live_values', 'test_values')->get();

        foreach ($rows as $row) {
            $update = [];

            if (!$this->isEncrypted($row->live_values)) {
                $update['live_values'] = Crypt::encrypt((string)$row->live_values, false);
            }

            if (!$this->isEncrypted($row->test_values)) {
                $update['test_values'] = Crypt::encrypt((string)$row->test_values, false);
            }

            if ($update) {
                DB::table('addon_settings')->where('id', $row->id)->update($update);
            }
        }
    }

    public function down(): void
    {
        $rows = DB::table('addon_settings')->select('id', 'live_values', 'test_values')->get();

        foreach ($rows as $row) {
            DB::table('addon_settings')->where('id', $row->id)->update([
                'live_values' => $this->decryptIfPossible($row->live_values),
                'test_values' => $this->decryptIfPossible($row->test_values),
            ]);
        }
    }

    private function isEncrypted(?string $value): bool
    {
        if ($value === null || $value === '') {
            return true;
        }

        try {
            Crypt::decrypt($value, false);
            return true;
        } catch (\Throwable) {
            return false;
        }
    }

    private function decryptIfPossible(?string $value): ?string
    {
        if ($value === null || $value === '') {
            return $value;
        }

        try {
            return Crypt::decrypt($value, false);
        } catch (\Throwable) {
            return $value;
        }
    }
};
