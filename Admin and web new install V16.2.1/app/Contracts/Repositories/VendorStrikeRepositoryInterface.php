<?php

namespace App\Contracts\Repositories;

interface VendorStrikeRepositoryInterface extends RepositoryInterface
{
    public function countRecentForSeller(int $sellerId, int $days): int;
}
