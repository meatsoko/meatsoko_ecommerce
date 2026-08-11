<?php

use App\Http\Controllers\Affiliate\Auth\LoginController;
use App\Http\Controllers\Affiliate\Auth\RegisterController;
use App\Http\Controllers\Affiliate\DashboardController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'affiliate', 'as' => 'affiliate.'], function () {

    Route::group(['prefix' => 'auth', 'as' => 'auth.'], function () {
        Route::controller(LoginController::class)->group(function () {
            Route::get('login', 'getLoginView')->name('login');
            Route::post('login', 'login')->name('login.submit');
            Route::get('logout', 'logout')->name('logout');
        });
        Route::controller(RegisterController::class)->group(function () {
            Route::get('register', 'getRegisterView')->name('register');
            Route::post('register', 'register')->name('register.submit');
        });
    });

    Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');
});
