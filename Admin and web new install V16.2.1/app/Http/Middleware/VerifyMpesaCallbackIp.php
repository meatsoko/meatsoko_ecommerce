<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\IpUtils;

/**
 * Safaricom does not sign Daraja STK Push callback payloads, so anyone who
 * discovers this public URL can POST a fake "payment confirmed" callback.
 * When MPESA_ALLOWED_IPS is set (comma-separated IPs/CIDR ranges, get the
 * current list from Safaricom support before go-live), only requests from
 * those addresses are accepted. Left unset, this middleware is a no-op so
 * sandbox/dev setups aren't blocked by default.
 */
class VerifyMpesaCallbackIp
{
    public function handle(Request $request, Closure $next)
    {
        $allowed = array_filter(array_map('trim', explode(',', (string) env('MPESA_ALLOWED_IPS', ''))));

        if (empty($allowed)) {
            return $next($request);
        }

        if (!IpUtils::checkIp($request->ip(), $allowed)) {
            Log::warning('Mpesa callback rejected: source IP not in MPESA_ALLOWED_IPS', [
                'ip' => $request->ip(),
                'path' => $request->path(),
            ]);
            return response()->json(['ResultCode' => 1, 'ResultDesc' => 'Rejected'], 403);
        }

        return $next($request);
    }
}
