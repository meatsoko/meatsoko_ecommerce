<?php

namespace App\Models;

use App\Traits\StorageTrait;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

/**
 * @property int $id
 * @property string $f_name
 * @property string|null $l_name
 * @property string|null $country_code
 * @property string|null $phone
 * @property string $email
 * @property string $password
 * @property string $image
 * @property string $affiliate_code
 * @property string $status pending|approved|suspended
 * @property string|null $auth_token
 */
class Affiliate extends Authenticatable
{
    use Notifiable, StorageTrait;

    protected $fillable = [
        'f_name',
        'l_name',
        'country_code',
        'phone',
        'email',
        'password',
        'image',
        'affiliate_code',
        'status',
        'auth_token',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'auth_token',
    ];

    protected $appends = ['image_full_url'];

    public function scopeApproved($query)
    {
        return $query->where(['status' => 'approved']);
    }

    public function wallet(): HasOne
    {
        return $this->hasOne(AffiliateWallet::class);
    }

    public function commissions(): HasMany
    {
        return $this->hasMany(AffiliateCommission::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class, 'affiliate_id');
    }

    public function getImageFullUrlAttribute(): array|string|null
    {
        $value = $this->image;
        if (count($this->storage ?? []) > 0) {
            $storage = $this->storage->where('key', 'image')->first();
        }
        return $this->storageLink('affiliate', $value, $storage['value'] ?? 'public');
    }
}
