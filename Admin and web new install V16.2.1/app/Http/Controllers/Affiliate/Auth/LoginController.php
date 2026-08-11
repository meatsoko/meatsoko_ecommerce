<?php

namespace App\Http\Controllers\Affiliate\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class LoginController extends Controller
{
    public function __construct()
    {
        $this->middleware('guest:affiliate', ['except' => ['logout']]);
    }

    public function getLoginView(): View
    {
        return view('affiliate-views.auth.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        $affiliate = \App\Models\Affiliate::where('email', $request['email'])->first();
        if ($affiliate && $affiliate->status !== 'approved') {
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
