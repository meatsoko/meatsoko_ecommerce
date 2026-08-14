<?php

namespace App\Services;

class AffiliateWithdrawService
{
    /**
     * Builds the wallet + request row updates for an admin approve/deny
     * decision. Approving moves the amount from pending_withdraw to
     * withdrawn; denying refunds it from pending_withdraw back to
     * total_earning (the affiliate's available balance) — mirrors the
     * Vendor withdraw approval math in Admin/Vendor/VendorController, since
     * AffiliateWallet's field names (total_earning/pending_withdraw/withdrawn)
     * match SellerWallet's exactly.
     *
     * @param object $request
     * @param object $wallet
     * @param object $withdraw
     * @return array{wallet: array, withdraw: array}
     */
    public function getUpdateData(object $request, object $wallet, object $withdraw): array
    {
        $amount = $withdraw['amount'] ?? 0;
        $totalEarning = $wallet['total_earning'] ?? 0;
        $pendingWithdraw = $wallet['pending_withdraw'] ?? 0;
        $withdrawn = $wallet['withdrawn'] ?? 0;

        $walletData = ['pending_withdraw' => $pendingWithdraw - $amount];
        if ($request['approved'] == 1) {
            $walletData['withdrawn'] = $withdrawn + $amount;
        } else {
            $walletData['total_earning'] = $totalEarning + $amount;
        }

        return [
            'wallet' => $walletData,
            'withdraw' => [
                'approved' => $request['approved'],
                'transaction_note' => $request['note'],
                'admin_id' => auth('admin')->id(),
            ],
        ];
    }
}
