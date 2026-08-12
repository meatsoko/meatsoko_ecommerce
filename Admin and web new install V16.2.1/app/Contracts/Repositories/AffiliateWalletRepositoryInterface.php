<?php

namespace App\Contracts\Repositories;

interface AffiliateWalletRepositoryInterface extends RepositoryInterface
{
    /**
     * Creates the affiliate's wallet on first credit if it doesn't exist yet,
     * then atomically increments total_earning — the single place "credit an
     * affiliate wallet" happens, instead of each payout call site repeating
     * its own firstOrCreate()+increment().
     */
    public function creditEarning(int|string $affiliateId, float $amount): void;
}
