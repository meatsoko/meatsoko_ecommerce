<?php

namespace App\Contracts\Repositories;

interface AffiliateRepositoryInterface extends RepositoryInterface
{
    public function findByCode(string $code): ?object;
}
