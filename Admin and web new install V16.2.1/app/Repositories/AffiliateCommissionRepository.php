<?php

namespace App\Repositories;

use App\Contracts\Repositories\AffiliateCommissionRepositoryInterface;
use App\Models\AffiliateCommission;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class AffiliateCommissionRepository extends AbstractSimpleRepository implements AffiliateCommissionRepositoryInterface
{
    public function __construct(AffiliateCommission $model)
    {
        parent::__construct($model);
    }

    public function getListWhere(array $orderBy = [], ?string $searchValue = null, array $filters = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(isset($filters['affiliate_id']), function ($query) use ($filters) {
                return $query->where(['affiliate_id' => $filters['affiliate_id']]);
            })
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit)->appends($filters);
    }

    public function existsForOrder(int $orderId): bool
    {
        return $this->model->where('order_id', $orderId)->exists();
    }

    public function sumForAffiliate(int $affiliateId): float
    {
        return (float)$this->model->where('affiliate_id', $affiliateId)->sum('amount');
    }
}
