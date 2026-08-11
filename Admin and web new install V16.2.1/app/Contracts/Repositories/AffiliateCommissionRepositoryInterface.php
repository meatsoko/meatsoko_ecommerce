<?php

namespace App\Contracts\Repositories;

interface AffiliateCommissionRepositoryInterface extends RepositoryInterface
{
    public function existsForOrder(int $orderId): bool;

    public function sumForAffiliate(int $affiliateId): float;
}
