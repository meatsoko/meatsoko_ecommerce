<?php

namespace App\Http\Controllers\Affiliate\Auth;

use App\Contracts\Repositories\AffiliateRepositoryInterface;
use App\Contracts\Repositories\AffiliateWalletRepositoryInterface;
use App\Http\Controllers\Controller;
use App\Utils\Helpers;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class RegisterController extends Controller
{
    public function __construct(
        private readonly AffiliateRepositoryInterface       $affiliateRepo,
        private readonly AffiliateWalletRepositoryInterface $affiliateWalletRepo,
    )
    {
        $this->middleware('guest:affiliate');
    }

    public function getRegisterView(): View
    {
        return view('affiliate-views.auth.register');
    }

    public function register(Request $request): RedirectResponse
    {
        $validator = Validator::make($request->all(), [
            'f_name' => 'required|string|max:30',
            'l_name' => 'nullable|string|max:30',
            'phone' => 'nullable|string|max:25',
            'email' => 'required|email|unique:affiliates,email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        $affiliate = $this->affiliateRepo->add([
            'f_name' => $request['f_name'],
            'l_name' => $request['l_name'],
            'phone' => $request['phone'],
            'email' => $request['email'],
            'password' => Hash::make($request['password']),
            'affiliate_code' => Helpers::generate_affiliate_code(),
            // Requires admin approval before login/earning — mirrors how
            // vendor accounts start 'pending', which keeps a commission-paying
            // signup form from being an open spam/fraud vector.
            'status' => 'pending',
        ]);

        $this->affiliateWalletRepo->add([
            'affiliate_id' => $affiliate->id,
            'total_earning' => 0,
            'pending_withdraw' => 0,
            'withdrawn' => 0,
        ]);

        return redirect()->route('affiliate.auth.login')
            ->with('success', translate('registration_successful_your_account_is_pending_admin_approval'));
    }
}
