<?php

namespace App\Console\Commands;

use App\Http\Controllers\Payment_Methods\MpesaC2bController;
use Illuminate\Console\Command;

class MpesaRegisterC2bUrls extends Command
{
    protected $signature = 'mpesa:register-c2b-urls';

    protected $description = 'Register the M-Pesa C2B Validation and Confirmation webhook URLs with Safaricom for the configured Paybill/Till shortcode';

    public function handle(MpesaC2bController $controller): void
    {
        $response = $controller->registerUrls()->getData(true);

        if (($response['status'] ?? 0) == 1) {
            $this->info('M-Pesa C2B URLs registered: ' . json_encode($response['response'] ?? []));
        } else {
            $this->error('Failed to register M-Pesa C2B URLs: ' . ($response['message'] ?? 'unknown error'));
        }
    }
}
