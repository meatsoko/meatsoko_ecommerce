<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * One credited commission per order — see the create_affiliate_commissions_table
 * migration for why this is only ever written once, at delivery.
 *
 * @property int $id
 * @property int $affiliate_id
 * @property int $order_id
 * @property float $order_amount
 * @property float $commission_rate
 * @property float $amount
 */
class AffiliateCommission extends Model
{
    protected $fillable = [
        'affiliate_id',
        'order_id',
        'order_amount',
        'commission_rate',
        'amount',
    ];

    protected $casts = [
        'affiliate_id' => 'integer',
        'order_id' => 'integer',
        'order_amount' => 'float',
        'commission_rate' => 'float',
        'amount' => 'float',
    ];

    public function affiliate(): BelongsTo
    {
        return $this->belongsTo(Affiliate::class);
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
