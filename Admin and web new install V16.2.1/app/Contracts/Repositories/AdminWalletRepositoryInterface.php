<?php

namespace App\Contracts\Repositories;

interface AdminWalletRepositoryInterface extends RepositoryInterface
{
    /**
     * @param array $params
     * @param array $data
     * @return bool
     */
    public function updateWhere(array $params, array $data): bool;

    /**
     * Atomic column increment (a single UPDATE ... SET col = col + amount),
     * unlike updateWhere() which needs a pre-fetched value and isn't safe
     * for concurrent credits to the same row.
     */
    public function incrementWhere(array $params, string $column, float $amount): bool;

}
