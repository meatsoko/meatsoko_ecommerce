<?php

namespace App\Repositories;

use App\Contracts\Repositories\SubscriptionPlanProductRepositoryInterface;
use App\Models\SubscriptionPlanProduct;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class SubscriptionPlanProductRepository extends AbstractSimpleRepository implements SubscriptionPlanProductRepositoryInterface
{
    public function __construct(SubscriptionPlanProduct $model)
    {
        parent::__construct($model);
    }

    public function getListWhere(array $orderBy = [], ?string $searchValue = null, array $filters = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(isset($filters['subscription_plan_id']), function ($query) use ($filters) {
                return $query->where(['subscription_plan_id' => $filters['subscription_plan_id']]);
            })
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit)->appends($filters);
    }
}
