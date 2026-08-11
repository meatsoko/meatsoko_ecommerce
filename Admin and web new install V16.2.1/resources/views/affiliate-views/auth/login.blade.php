@extends('layouts.affiliate.app')
@section('title', translate('Affiliate_Login'))
@section('content')
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4">
            <div class="affiliate-card p-4 mt-4">
                <h4 class="mb-4">{{ translate('Affiliate_Login') }}</h4>
                <form method="post" action="{{ route('affiliate.auth.login.submit') }}">
                    @csrf
                    <div class="mb-3">
                        <label class="form-label">{{ translate('email') }}</label>
                        <input type="email" name="email" class="form-control" value="{{ old('email') }}" required autofocus>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">{{ translate('password') }}</label>
                        <input type="password" name="password" class="form-control" required>
                    </div>
                    <div class="form-check mb-3">
                        <input type="checkbox" name="remember" value="1" class="form-check-input" id="remember">
                        <label class="form-check-label" for="remember">{{ translate('remember_me') }}</label>
                    </div>
                    <button type="submit" class="btn btn-dark w-100">{{ translate('login') }}</button>
                </form>
                <p class="text-center small text-muted mt-3 mb-0">
                    {{ translate('dont_have_an_account') }}?
                    <a href="{{ route('affiliate.auth.register') }}">{{ translate('register_as_an_affiliate') }}</a>
                </p>
            </div>
        </div>
    </div>
@endsection
