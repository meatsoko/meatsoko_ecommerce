<?php

namespace App\Http\Controllers\Affiliate\Auth;

use App\Contracts\Repositories\AffiliateRepositoryInterface;
use App\Http\Controllers\Controller;
use App\Http\Requests\Affiliate\LoginRequest;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    public function __construct(
        private readonly AffiliateRepositoryInterface $affiliateRepo,
    )
    {
        $this->middleware('guest:affiliate', ['except' => ['logout']]);
    }

    public function getLoginView(): View
    {
        return view('affiliate-views.auth.login');
    }

    public function login(LoginRequest $request): RedirectResponse
    {
        $affiliate = $this->affiliateRepo->getFirstWhere(['email' => $request['email']]);
        if ($affiliate && $affiliate['status'] !== 'approved') {
            return back()->with('error', translate('your_account_is_pending_admin_approval_or_has_been_suspended'))->withInput();
        }

        if (Auth::guard('affiliate')->attempt(['email' => $request['email'], 'password' => $request['password']], $request->boolean('remember'))) {
            return redirect()->route('affiliate.dashboard');
        }

        return back()->with('error', translate('credentials_doesnt_match'))->withInput();
    }

    public function logout(): RedirectResponse
    {
        Auth::guard('affiliate')->logout();
        return redirect()->route('affiliate.auth.login')->with('success', translate('logged_out_successfully'));
    }
}
