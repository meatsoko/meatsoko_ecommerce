@extends('layouts.affiliate.app')
@section('title', translate('Affiliate_Registration'))
@section('content')
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="affiliate-card p-4 mt-4">
                <h4 class="mb-1">{{ translate('Become_an_Affiliate') }}</h4>
                <p class="text-muted small mb-4">{{ translate('get_your_own_referral_link_and_earn_commission_on_every_purchase_you_bring_in') }}</p>
                <form method="post" action="{{ route('affiliate.auth.register.submit') }}">
                    @csrf
                    <div class="row g-3">
                        <div class="col-6">
                            <label class="form-label">{{ translate('first_name') }}</label>
                            <input type="text" name="f_name" class="form-control" value="{{ old('f_name') }}" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">{{ translate('last_name') }}</label>
                            <input type="text" name="l_name" class="form-control" value="{{ old('l_name') }}">
                        </div>
                        <div class="col-12">
                            <label class="form-label">{{ translate('email') }}</label>
                            <input type="email" name="email" class="form-control" value="{{ old('email') }}" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label">{{ translate('phone') }}</label>
                            <input type="text" name="phone" class="form-control" value="{{ old('phone') }}">
                        </div>
                        <div class="col-6">
                            <label class="form-label">{{ translate('password') }}</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">{{ translate('confirm_password') }}</label>
                            <input type="password" name="password_confirmation" class="form-control" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-dark w-100 mt-4">{{ translate('register') }}</button>
                </form>
                <p class="text-center small text-muted mt-3 mb-0">
                    {{ translate('already_have_an_account') }}?
                    <a href="{{ route('affiliate.auth.login') }}">{{ translate('login') }}</a>
                </p>
            </div>
        </div>
    </div>
@endsection
