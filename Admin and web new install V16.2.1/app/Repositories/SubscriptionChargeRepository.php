<?php

namespace App\Repositories;

use App\Contracts\Repositories\SubscriptionChargeRepositoryInterface;
use App\Models\SubscriptionCharge;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class SubscriptionChargeRepository extends AbstractSimpleRepository implements SubscriptionChargeRepositoryInterface
{
    public function __construct(SubscriptionCharge $model)
    {
        parent::__construct($model);
    }

    public function getListWhere(array $orderBy = [], ?string $searchValue = null, array $filters = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(isset($filters['customer_subscription_id']), function ($query) use ($filters) {
                return $query->where(['customer_subscription_id' => $filters['customer_subscription_id']]);
            })
            ->when(isset($filters['status']), function ($query) use ($filters) {
                return $query->where(['status' => $filters['status']]);
            })
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit)->appends($filters);
    }
}
