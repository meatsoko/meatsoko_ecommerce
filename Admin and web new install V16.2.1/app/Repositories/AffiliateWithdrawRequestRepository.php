<?php

namespace App\Repositories;

use App\Contracts\Repositories\AffiliateWithdrawRequestRepositoryInterface;
use App\Models\AffiliateWithdrawRequest;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class AffiliateWithdrawRequestRepository extends AbstractSimpleRepository implements AffiliateWithdrawRequestRepositoryInterface
{
    public function __construct(AffiliateWithdrawRequest $model)
    {
        parent::__construct($model);
    }

    public function getListWhere(array $orderBy = [], ?string $searchValue = null, array $filters = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(isset($filters['affiliate_id']), function ($query) use ($filters) {
                return $query->where(['affiliate_id' => $filters['affiliate_id']]);
            })
            ->when(($filters['status'] ?? null) === 'approved', function ($query) {
                return $query->where('approved', 1);
            })
            ->when(($filters['status'] ?? null) === 'denied', function ($query) {
                return $query->where('approved', 2);
            })
            ->when(($filters['status'] ?? null) === 'pending', function ($query) {
                return $query->where('approved', 0);
            })
            ->when($searchValue, function ($query) use ($searchValue) {
                return $query->whereHas('affiliate', function ($query) use ($searchValue) {
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
}
