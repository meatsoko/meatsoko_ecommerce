<?php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use HasFactory;
    use HasUuid;

    protected $table = 'addon_settings';

    protected $casts = [
        'live_values' => 'encrypted:array',
        'test_values' => 'encrypted:array',
        'is_active' => 'integer',
    ];

    protected $fillable = ['id', 'key_name', 'live_values', 'test_values', 'settings_type', 'mode', 'is_active', 'additional_data', 'created_at', 'updated_at'];
}
