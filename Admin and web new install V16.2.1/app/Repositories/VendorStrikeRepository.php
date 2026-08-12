<?php

namespace App\Repositories;

use App\Contracts\Repositories\VendorStrikeRepositoryInterface;
use App\Models\VendorStrike;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Pagination\LengthAwarePaginator;

class VendorStrikeRepository extends AbstractSimpleRepository implements VendorStrikeRepositoryInterface
{
    public function __construct(VendorStrike $model)
    {
        parent::__construct($model);
    }

    public function getFirstWhere(array $params, array $relations = []): ?Model
    {
        return $this->model->with($relations)->where($params)->latest()->first();
    }

    public function getListWhere(array $orderBy = [], ?string $searchValue = null, array $filters = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(isset($filters['seller_id']), function ($query) use ($filters) {
                return $query->where(['seller_id' => $filters['seller_id']]);
            })
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit)->appends($filters);
    }

    /**
     * Number of strikes a seller has picked up in the last $days — the signal
     * used to decide whether their withdrawal requests fast-track or go
     * through manual review.
     */
    public function countRecentForSeller(int $sellerId, int $days): int
    {
        return $this->model
            ->where('seller_id', $sellerId)
            ->where('created_at', '>=', Carbon::now()->subDays($days))
            ->count();
    }
}
