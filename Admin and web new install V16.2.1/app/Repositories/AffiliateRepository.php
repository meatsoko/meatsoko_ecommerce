<?php

namespace App\Repositories;

use App\Contracts\Repositories\AffiliateRepositoryInterface;
use App\Models\Affiliate;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class AffiliateRepository extends AbstractSimpleRepository implements AffiliateRepositoryInterface
{
    public function __construct(Affiliate $model)
    {
        parent::__construct($model);
    }

    public function getListWhere(array $orderBy = [], ?string $searchValue = null, array $filters = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(isset($filters['status']), function ($query) use ($filters) {
                return $query->where(['status' => $filters['status']]);
            })
            ->when($searchValue, function ($query) use ($searchValue) {
                return $query->where(function ($query) use ($searchValue) {
                    $query->where('f_name', 'like', "%{$searchValue}%")
                        ->orWhere('email', 'like', "%{$searchValue}%")
                        ->orWhere('affiliate_code', 'like', "%{$searchValue}%");
                });
            })
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit)->appends($filters);
    }

    public function findByCode(string $code): ?object
    {
        return $this->model->where('affiliate_code', $code)->approved()->first();
    }
}
