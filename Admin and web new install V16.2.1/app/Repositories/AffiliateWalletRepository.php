<?php

namespace App\Repositories;

use App\Contracts\Repositories\AffiliateWalletRepositoryInterface;
use App\Models\AffiliateWallet;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class AffiliateWalletRepository extends AbstractSimpleRepository implements AffiliateWalletRepositoryInterface
{
    public function __construct(AffiliateWallet $model)
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

    public function creditEarning(int|string $affiliateId, float $amount): void
    {
        $wallet = $this->model->firstOrCreate(
            ['affiliate_id' => $affiliateId],
            ['total_earning' => 0, 'pending_withdraw' => 0, 'withdrawn' => 0]
        );
        $wallet->increment('total_earning', $amount);
    }
}
