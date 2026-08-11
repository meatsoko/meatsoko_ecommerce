<?php

namespace App\Repositories;

use App\Contracts\Repositories\AdPlacementRepositoryInterface;
use App\Models\AdPlacement;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Pagination\LengthAwarePaginator;

class AdPlacementRepository implements AdPlacementRepositoryInterface
{
    public function __construct(
        private readonly AdPlacement $model
    )
    {
    }

    public function add(array $data): string|object
    {
        return $this->model->newInstance()->create($data);
    }

    public function getFirstWhere(array $params, array $relations = []): ?Model
    {
        return $this->model->with($relations)->where($params)->latest()->first();
    }

    public function getList(array $orderBy = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit);
    }

    public function getListWhere(array $orderBy = [], ?string $searchValue = null, array $filters = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(isset($filters['seller_id']), function ($query) use ($filters) {
                return $query->where(['seller_id' => $filters['seller_id']]);
            })
            ->when(isset($filters['status']), function ($query) use ($filters) {
                return $query->where(['status' => $filters['status']]);
            })
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit)->appends($filters);
    }

    public function update(string $id, array $data): bool
    {
        return $this->model->where('id', $id)->update($data);
    }

    public function delete(array $params): bool
    {
        return (bool)$this->model->where($params)->delete();
    }

    /**
     * A product can only have one live-or-about-to-be-live placement at a
     * time — prevents a vendor double-booking (and double-paying for) the
     * same product's sponsored slot.
     */
    public function hasActiveOrPendingForProduct(int $productId): bool
    {
        return $this->model
            ->where('product_id', $productId)
            ->whereIn('status', ['pending', 'active'])
            ->exists();
    }
}
