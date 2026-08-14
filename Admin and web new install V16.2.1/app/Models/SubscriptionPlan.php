<?php

namespace App\Models;

use App\Traits\StorageTrait;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property int $id
 * @property string $title
 * @property string $cadence weekly|monthly
 * @property float $price
 * @property float $shipping_cost
 * @property string|null $image
 * @property string $status active|inactive
 */
class SubscriptionPlan extends Model
{
    use StorageTrait;

    protected $fillable = [
        'title',
        'cadence',
        'price',
        'shipping_cost',
        'image',
        'status',
    ];

    protected $casts = [
        'price' => 'float',
        'shipping_cost' => 'float',
    ];

    protected $appends = ['image_full_url'];

    public function scopeActive($query)
    {
        return $query->where(['status' => 'active']);
    }

    public function products(): HasMany
    {
        return $this->hasMany(SubscriptionPlanProduct::class);
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(CustomerSubscription::class);
    }

    public function getImageFullUrlAttribute(): array|string|null
    {
        $value = $this->image;
        if (count($this->storage ?? []) > 0) {
            $storage = $this->storage->where('key', 'image')->first();
        }
        return $this->storageLink('subscription-plan', $value, $storage['value'] ?? 'public');
    }
}
