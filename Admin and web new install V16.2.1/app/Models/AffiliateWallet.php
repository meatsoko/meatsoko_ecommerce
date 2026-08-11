<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $affiliate_id
 * @property float $total_earning
 * @property float $pending_withdraw
 * @property float $withdrawn
 */
class AffiliateWallet extends Model
{
    protected $fillable = [
        'affiliate_id',
        'total_earning',
        'pending_withdraw',
        'withdrawn',
    ];

    protected $casts = [
        'affiliate_id' => 'integer',
        'total_earning' => 'float',
        'pending_withdraw' => 'float',
        'withdrawn' => 'float',
    ];

    public function affiliate(): BelongsTo
    {
        return $this->belongsTo(Affiliate::class);
    }
}
