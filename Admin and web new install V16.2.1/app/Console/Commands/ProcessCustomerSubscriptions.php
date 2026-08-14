<?php

namespace App\Console\Commands;

use App\Contracts\Repositories\CustomerSubscriptionRepositoryInterface;
use App\Services\SubscriptionBillingService;
use Illuminate\Console\Command;

class ProcessCustomerSubscriptions extends Command
{
    protected $signature = 'subscriptions:bill-due';

    protected $description = 'Charges every active customer subscription whose next billing date has arrived';

    public function handle(CustomerSubscriptionRepositoryInterface $subscriptionRepo, SubscriptionBillingService $billingService): void
    {
        $due = $subscriptionRepo->getDue();

        $charged = 0;
        foreach ($due as $subscription) {
            $billingService->chargeSubscription($subscription);
            $charged++;
        }

        $this->info("Processed {$charged} due subscription(s).");
    }
}
