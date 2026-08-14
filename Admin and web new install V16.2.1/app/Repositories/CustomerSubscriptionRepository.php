<?php

namespace App\Repositories;

use App\Contracts\Repositories\CustomerSubscriptionRepositoryInterface;
use App\Models\CustomerSubscription;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class CustomerSubscriptionRepository extends AbstractSimpleRepository implements CustomerSubscriptionRepositoryInterface
{
    public function __construct(CustomerSubscription $model)
    {
        parent::__construct($model);
    }

    public function getListWhere(array $orderBy = [], ?string $searchValue = null, array $filters = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(isset($filters['customer_id']), function ($query) use ($filters) {
                return $query->where(['customer_id' => $filters['customer_id']]);
            })
            ->when(isset($filters['status']), function ($query) use ($filters) {
                return $query->where(['status' => $filters['status']]);
            })
            ->when(isset($filters['subscription_plan_id']), function ($query) use ($filters) {
                return $query->where(['subscription_plan_id' => $filters['subscription_plan_id']]);
            })
            ->when($searchValue, function ($query) use ($searchValue) {
                return $query->whereHas('customer', function ($query) use ($searchValue) {
                    $query->where('f_name', 'like', "%{$searchValue}%")
                        ->orWhere('l_name', 'like', "%{$searchValue}%")
                        ->orWhere('email', 'like', "%{$searchValue}%")
                        ->orWhere('phone', 'like', "%{$searchValue}%");
                });
            })
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit)->appends($filters);
    }

    public function getDue(): \Illuminate\Support\Collection
    {
        return $this->model->dueToday()->with(['plan', 'customer'])->get();
    }
}
