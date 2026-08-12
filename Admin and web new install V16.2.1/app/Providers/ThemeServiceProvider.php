<?php

namespace App\Providers;

use Illuminate\Support\Facades\App;
use Illuminate\Support\ServiceProvider;

class ThemeServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register(): void
    {
        // runningInConsole() is also true for PHPUnit's HTTP test client (it's
        // still a CLI process) — without the runningUnitTests() carve-out, no
        // feature test hitting a storefront route can ever resolve a view.
        if (!App::runningInConsole() || App::runningUnitTests()) {
            $theme = env('WEB_THEME') == null ? 'default' : env('WEB_THEME');
            $path = base_path('resources/themes/' . $theme);
            if (!defined('VIEW_FILE_NAMES')) {
                define("VIEW_FILE_NAMES", include($path . '/file_names.php'));
            }
            view()->addLocation($path);
        }
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {

    }
}
