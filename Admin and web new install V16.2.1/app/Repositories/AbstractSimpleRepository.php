<?php

namespace App\Repositories;

use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Pagination\LengthAwarePaginator;

/**
 * add()/getFirstWhere()/getList()/update()/delete() are identical across
 * every "one model, no bespoke filtering beyond getListWhere()" repository —
 * this is the one place that shape lives instead of being copy-pasted per
 * repository (AdPlacement, Affiliate, AffiliateCommission, AffiliateWallet,
 * VendorStrike all extend this). getListWhere() is deliberately NOT
 * included: each repository's filterable columns differ enough that forcing
 * them through one generic filter map would be its own source of bugs, so
 * it stays implemented per-repository.
 */
abstract class AbstractSimpleRepository
{
    public function __construct(protected readonly Model $model)
    {
    }

    public function add(array $data): string|object
    {
        return $this->model->newInstance()->create($data);
    }

    public function getFirstWhere(array $params, array $relations = []): ?Model
    {
        return $this->model->with($relations)->where($params)->first();
    }

    public function getList(array $orderBy = [], array $relations = [], int|string $dataLimit = DEFAULT_DATA_LIMIT, ?int $offset = null): Collection|LengthAwarePaginator
    {
        $query = $this->model->with($relations)
            ->when(!empty($orderBy), function ($query) use ($orderBy) {
                return $query->orderBy(array_key_first($orderBy), array_values($orderBy)[0]);
            });

        return $dataLimit == 'all' ? $query->get() : $query->paginate($dataLimit);
    }

    public function update(string $id, array $data): bool
    {
        return $this->model->where('id', $id)->update($data);
    }

    public function delete(array $params): bool
    {
        return (bool)$this->model->where($params)->delete();
    }
}
