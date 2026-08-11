<?php

namespace App\Contracts\Repositories;

interface AdPlacementRepositoryInterface extends RepositoryInterface
{
    public function hasActiveOrPendingForProduct(int $productId): bool;
}
