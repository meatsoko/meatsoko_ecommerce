<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * A vendor-purchased "Sponsored" slot for one of their own products, shown
 * in the homepage sponsored-products section for [start_at, end_at]. See
 * app/Console/Commands/ExpireAdPlacements.php for how status transitions
 * from active -> expired (never computed on the fly).
 *
 * @property int $id
 * @property int $seller_id
 * @property int $product_id
 * @property int $days
 * @property float $amount_paid
 * @property \Illuminate\Support\Carbon|null $start_at
 * @property \Illuminate\Support\Carbon|null $end_at
 * @property string $status pending|active|expired
 * @property string|null $payment_request_id
 */
class AdPlacement extends Model
{
    protected $fillable = [
        'seller_id',
        'product_id',
        'days',
        'amount_paid',
        'start_at',
        'end_at',
        'status',
        'payment_request_id',
    ];

    protected $casts = [
        'seller_id' => 'integer',
        'product_id' => 'integer',
        'days' => 'integer',
        'amount_paid' => 'float',
        'start_at' => 'datetime',
        'end_at' => 'datetime',
    ];

    public function scopeActive($query)
    {
        return $query->where('status', 'active')->where('end_at', '>', now());
    }

    public function seller(): BelongsTo
    {
        return $this->belongsTo(Seller::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
