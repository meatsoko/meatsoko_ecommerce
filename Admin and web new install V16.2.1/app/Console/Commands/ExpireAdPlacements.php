<?php

namespace App\Console\Commands;

use App\Models\AdPlacement;
use Illuminate\Console\Command;

/**
 * A lapsed placement's status is only ever flipped here, never computed on
 * the fly — ProductManager::getSponsoredProductsQuery() and every other
 * "is this active" check reads AdPlacement::scopeActive() (status=active AND
 * end_at > now), so as long as this runs regularly, expired placements just
 * stop showing up; nothing downstream needs to know why.
 */
class ExpireAdPlacements extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'ads:expire-placements';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Marks sponsored-product placements whose end_at has passed as expired';

    public function handle(): void
    {
        $count = AdPlacement::where('status', 'active')
            ->where('end_at', '<=', now())
            ->update(['status' => 'expired']);

        $this->info("Expired {$count} ad placement(s).");
    }
}
