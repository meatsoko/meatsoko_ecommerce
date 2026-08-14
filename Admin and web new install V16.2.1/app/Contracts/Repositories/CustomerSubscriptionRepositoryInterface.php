<?php

namespace App\Contracts\Repositories;

use Illuminate\Support\Collection;

interface CustomerSubscriptionRepositoryInterface extends RepositoryInterface
{
    /**
     * Subscriptions due to be billed today or earlier — the query the
     * billing command runs. Kept on the repository rather than inlined in
     * the command so it stays covered by the same layering as everything
     * else (Controller/Command → Repository → Model).
     */
    public function getDue(): Collection;
}
