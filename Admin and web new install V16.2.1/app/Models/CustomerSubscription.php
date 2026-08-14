<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property int $id
 * @property int $customer_id
 * @property int $subscription_plan_id
 * @property string $payment_method wallet|mpesa
 * @property string|null $phone
 * @property int $shipping_address_id
 * @property string $status active|paused|cancelled
 * @property \Illuminate\Support\Carbon $next_billing_date
 * @property int $failed_attempts
 * @property \Illuminate\Support\Carbon|null $last_charged_at
 */
class CustomerSubscription extends Model
{
    protected $fillable = [
        'customer_id',
        'subscription_plan_id',
        'payment_method',
        'phone',
        'shipping_address_id',
        'status',
        'next_billing_date',
        'failed_attempts',
        'last_charged_at',
    ];

    protected $casts = [
        'next_billing_date' => 'date',
        'failed_attempts' => 'integer',
        'last_charged_at' => 'datetime',
    ];

    public function scopeDueToday($query)
    {
        return $query->where('status', 'active')->whereDate('next_billing_date', '<=', now()->toDateString());
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(SubscriptionPlan::class, 'subscription_plan_id');
    }

    public function shippingAddress(): BelongsTo
    {
        return $this->belongsTo(ShippingAddress::class, 'shipping_address_id');
    }

    public function charges(): HasMany
    {
        return $this->hasMany(SubscriptionCharge::class);
    }
}
