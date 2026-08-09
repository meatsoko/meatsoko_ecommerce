<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * A logged instance of a vendor being flagged for an off-platform
 * contact-sharing attempt (tied to a Chatting row where possible) or another
 * admin-reviewed policy violation. Used to gate withdrawal fast-tracking —
 * see WithdrawRequestRepository / Vendor withdraw flow.
 *
 * @property int $id
 * @property int $seller_id
 * @property int|null $chatting_id
 * @property string $reason
 * @property int|null $issued_by_admin_id
 */
class VendorStrike extends Model
{
    protected $fillable = [
        'seller_id',
        'chatting_id',
        'reason',
        'issued_by_admin_id',
    ];

    protected $casts = [
        'seller_id' => 'integer',
        'chatting_id' => 'integer',
        'issued_by_admin_id' => 'integer',
    ];

    public function seller(): BelongsTo
    {
        return $this->belongsTo(Seller::class, 'seller_id');
    }

    public function chatting(): BelongsTo
    {
        return $this->belongsTo(Chatting::class, 'chatting_id');
    }
}
