<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $customer_subscription_id
 * @property int|null $order_id
 * @property float $amount
 * @property string $payment_method wallet|mpesa
 * @property string $status pending|success|failed
 * @property string|null $failure_reason
 * @property \Illuminate\Support\Carbon $attempted_at
 */
class SubscriptionCharge extends Model
{
    protected $fillable = [
        'customer_subscription_id',
        'order_id',
        'amount',
        'payment_method',
        'status',
        'failure_reason',
        'attempted_at',
    ];

    protected $casts = [
        'amount' => 'float',
        'attempted_at' => 'datetime',
    ];

    public function subscription(): BelongsTo
    {
        return $this->belongsTo(CustomerSubscription::class, 'customer_subscription_id');
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
