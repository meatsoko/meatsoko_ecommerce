<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $affiliate_id
 * @property float $amount
 * @property string|null $transaction_note
 * @property int $approved 0=pending, 1=approved, 2=denied
 * @property int|null $admin_id
 */
class AffiliateWithdrawRequest extends Model
{
    protected $fillable = [
        'affiliate_id',
        'amount',
        'transaction_note',
        'approved',
        'admin_id',
    ];

    protected $casts = [
        'affiliate_id' => 'integer',
        'amount' => 'float',
        'approved' => 'integer',
        'admin_id' => 'integer',
    ];

    public function affiliate(): BelongsTo
    {
        return $this->belongsTo(Affiliate::class);
    }
}
