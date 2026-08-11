<?php

namespace App\Http\Middleware;

use App\Models\Affiliate;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cookie;

/**
 * Any page hit with ?ref=CODE (a link an affiliate shared — a specific
 * product page, a category, or the homepage) sets a 30-day cookie so a
 * purchase made on this or any later visit still attributes to that
 * affiliate. Last click wins — a newer ?ref= link overwrites an older one,
 * same as the industry-standard affiliate attribution model.
 *
 * Deliberately a global "web" group middleware rather than a route-specific
 * one: an affiliate's link has to work no matter which page it points at.
 */
class CaptureAffiliateReferral
{
    public const COOKIE_NAME = 'affiliate_ref';
    public const ATTRIBUTION_DAYS = 30;

    public function handle(Request $request, Closure $next)
    {
        $code = $request->query('ref');

        if ($code && Affiliate::where('affiliate_code', $code)->approved()->exists()) {
            Cookie::queue(self::COOKIE_NAME, $code, self::ATTRIBUTION_DAYS * 24 * 60);
        }

        return $next($request);
    }
}
