@extends('layouts.front-end.app')

@section('title', translate('sign_in'))

@push('css_or_js')
    <link rel="stylesheet"
        href="{{ theme_asset(path: 'public/assets/front-end/plugin/intl-tel-input/css/intlTelInput.css') }}">
@endpush

@section('content')

    <?php
    $customerManualLogin = $web_config['customer_login_options']['manual_login'] ?? 0;
    $customerOTPLogin = $web_config['customer_login_options']['otp_login'] ?? 0;
    $customerSocialLogin = $web_config['customer_login_options']['social_login'] ?? 0;

    if (!$customerOTPLogin && $customerManualLogin && $customerSocialLogin) {
        $multiColumn = 1;
    } elseif ($customerOTPLogin && !$customerManualLogin && $customerSocialLogin) {
        $multiColumn = 1;
    } elseif ($customerOTPLogin && $customerManualLogin && !$customerSocialLogin) {
        $multiColumn = 1;
    } elseif ($customerOTPLogin && $customerManualLogin && $customerSocialLogin) {
        $multiColumn = 1;
    } else {
        $multiColumn = 0;
    }
    ?>

    <div class="container py-4 py-lg-5 my-4 text-align-direction">
        <div class="ms-auth-layout ms-auth-layout--login">
            <div class="ms-auth-side">
                <span class="ms-eyebrow">Welcome back</span>
                <h2>Good to see you again.</h2>
                <p>Log in to pick up right where you left off — your details are already saved.</p>
                <ul>
                    <li><svg viewBox="0 0 24 24" fill="none"><path d="M9 12l2 2 4-4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.6"/></svg>Your delivery address is already saved</li>
                    <li><svg viewBox="0 0 24 24" fill="none"><path d="M3 12h4l2-7 4 14 2-7h6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>See your past and current orders instantly</li>
                    <li><svg viewBox="0 0 24 24" fill="none"><rect x="3" y="6" width="18" height="13" rx="2" stroke="currentColor" stroke-width="1.7"/><path d="M3 10h18" stroke="currentColor" stroke-width="1.7"/></svg>Checkout in a couple of taps</li>
                </ul>
            </div>
            <div class="ms-auth-form-wrap">
                <div class="ms-auth-tabs">
                    <span class="ms-auth-tab active">{{ translate('Sign_In') }}</span>
                    <a href="{{ route('customer.auth.sign-up') }}" class="ms-auth-tab">{{ translate('sign_up') }}</a>
                </div>
                <div class="ms-auth-panel">
                    <div
                        class="row justify-content-center align-items-center g-4 {{ $multiColumn ? 'or-sign-in-with-row' : '' }}">
                        @if ($customerOTPLogin && !$customerManualLogin && !$customerSocialLogin)
                            <div class="col-md-12">
                                <form autocomplete="off" action="{{ route('customer.auth.login') }}" method="post"
                                    id="customer-otp-login-form" class="customer-centralize-login-form"
                                    data-firebase-auth="{{ $web_config['firebase_otp_verification_status'] ? 'active' : 'deactivate' }}">
                                    @csrf
                                    <input type="hidden" name="keep_customer_login_redirect_url" value="{{ $keepCustomerLoginRedirectUrl ?? old('keep_customer_login_redirect_url', url()->previous()) }}">
                                    <input type="hidden" name="login_type" value="otp-login">
                                    @include('web-views.customer-views.auth.partials._phone')

                                    @include('web-views.customer-views.auth.partials._recaptcha')

                                    <button class="btn btn--primary btn-block btn-shadow font-semi-bold" type="submit">
                                        {{ translate('Get_OTP') }}
                                    </button>
                                </form>
                            </div>
                        @elseif(!$customerOTPLogin && $customerManualLogin && !$customerSocialLogin)
                            <div class="col-md-12">
                                <form autocomplete="off" class="customer-centralize-login-form mt-2"
                                    action="{{ route('customer.auth.login') }}" method="post" id="customer-login-form">
                                    @csrf
                                    <input type="hidden" name="keep_customer_login_redirect_url" value="{{ $keepCustomerLoginRedirectUrl ?? old('keep_customer_login_redirect_url', url()->previous()) }}">
                                    <input type="hidden" name="login_type" value="manual-login">
                                    @include('web-views.customer-views.auth.partials._email')
                                    @include('web-views.customer-views.auth.partials._password')
                                    @include('web-views.customer-views.auth.partials._remember-me', [
                                        'forgotPassword' => true,
                                    ])
                                    @include('web-views.customer-views.auth.partials._recaptcha')
                                    <button class="btn btn--primary btn-block btn-shadow font-semi-bold" type="submit">
                                        {{ translate('sign_in') }}
                                    </button>
                                    @if (!$multiColumn)
                                        @include('web-views.customer-views.auth.partials._sign-up-instruction')
                                    @endif
                                </form>
                            </div>
                        @elseif(!$customerOTPLogin && $customerManualLogin && $customerSocialLogin)
                            <div class="col-md-6">
                                <form autocomplete="off" class="customer-centralize-login-form mt-2"
                                    action="{{ route('customer.auth.login') }}" method="post" id="customer-login-form">
                                    @csrf
                                    <input type="hidden" name="keep_customer_login_redirect_url" value="{{ $keepCustomerLoginRedirectUrl ?? old('keep_customer_login_redirect_url', url()->previous()) }}">
                                    <input type="hidden" name="login_type" value="manual-login">
                                    @include('web-views.customer-views.auth.partials._email')
                                    @include('web-views.customer-views.auth.partials._password')
                                    @include('web-views.customer-views.auth.partials._remember-me', [
                                        'forgotPassword' => true,
                                    ])
                                    @include('web-views.customer-views.auth.partials._recaptcha')
                                    <button class="btn btn--primary btn-block btn-shadow font-semi-bold" type="submit">
                                        {{ translate('sign_in') }}
                                    </button>
                                    @if (!$multiColumn)
                                        @include('web-views.customer-views.auth.partials._sign-up-instruction')
                                    @endif

                                </form>
                            </div>
                        @elseif($customerOTPLogin && !$customerManualLogin && $customerSocialLogin)
                            <div class="col-md-6">
                                <form autocomplete="off" class="customer-centralize-login-form mt-2"
                                    action="{{ route('customer.auth.login') }}" method="post" id="customer-otp-login-form"
                                    data-firebase-auth="{{ $web_config['firebase_otp_verification_status'] ? 'active' : 'deactivate' }}">
                                    @csrf
                                    <input type="hidden" name="keep_customer_login_redirect_url" value="{{ $keepCustomerLoginRedirectUrl ?? old('keep_customer_login_redirect_url', url()->previous()) }}">
                                    <input type="hidden" name="login_type" value="otp-login">
                                    @include('web-views.customer-views.auth.partials._phone')
                                    @include('web-views.customer-views.auth.partials._recaptcha')

                                    <button class="btn btn--primary btn-block btn-shadow font-semi-bold" type="submit">
                                        {{ translate('Get_OTP') }}
                                    </button>
                                </form>
                            </div>
                        @elseif($customerOTPLogin && $customerManualLogin)
                            <div class="col-md-6">
                                <div class="manual-login-container">
                                    <form autocomplete="off" class="customer-centralize-login-form mt-2"
                                        action="{{ route('customer.auth.login') }}" method="post"
                                        id="customer-login-form">
                                        @csrf

                                        <input type="hidden" name="keep_customer_login_redirect_url" value="{{ $keepCustomerLoginRedirectUrl ?? old('keep_customer_login_redirect_url', url()->previous()) }}">
                                        <input type="hidden" name="login_type" class="auth-login-type-input"
                                            value="manual-login">

                                        <div class="manual-login-items">
                                            @include('web-views.customer-views.auth.partials._email')
                                            @include('web-views.customer-views.auth.partials._password')
                                            @include(
                                                'web-views.customer-views.auth.partials._remember-me',
                                                ['forgotPassword' => true]
                                            )
                                        </div>

                                        <div class="otp-login-items d-none">
                                            @include('web-views.customer-views.auth.partials._phone')
                                        </div>

                                        @include('web-views.customer-views.auth.partials._recaptcha')

                                        <div class="manual-login-items">
                                            <button class="btn btn--primary btn-block btn-shadow font-semi-bold"
                                                type="submit">
                                                {{ translate('sign_in') }}
                                            </button>
                                        </div>

                                        <div class="otp-login-items d-none">
                                            <button class="btn btn--primary btn-block btn-shadow font-semi-bold"
                                                type="submit">
                                                {{ translate('Get_OTP') }}
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        @endif

                        @if ($multiColumn)
                            <div class="or-sign-in-with"><span>{{ translate('Or Sign in with') }}</span></div>
                        @endif

                        @if ($multiColumn || $customerSocialLogin)
                            <div class="{{ $multiColumn ? 'col-md-6' : 'col-12' }}">
                                <div class="d-flex justify-content-center flex-column align-items-center my-3 gap-3">
                                    @if ($customerSocialLogin)
                                        @foreach ($web_config['customer_social_login_options'] as $socialLoginServiceKey => $socialLoginService)
                                            @if ($socialLoginService && $socialLoginServiceKey != 'apple')
                                                <a class="social-media-login-btn"
                                                    href="{{ route('customer.auth.service-login', $socialLoginServiceKey) }}">
                                                    <img alt=""
                                                        src="{{ theme_asset(path: 'public/assets/front-end/img/icons/' . $socialLoginServiceKey . '.png') }}">
                                                    <span class="text">
                                                        {{ translate($socialLoginServiceKey) }}
                                                    </span>
                                                </a>
                                            @endif
                                        @endforeach
                                    @endif
                                    @if ($customerOTPLogin && $customerManualLogin)
                                        <a class="social-media-login-btn otp-login-btn" href="javascript:">
                                            <img alt=""
                                                src="{{ theme_asset(path: 'public/assets/front-end/img/icons/otp-login-icon.svg') }}">
                                            <span class="text">{{ translate('OTP_Sign_in') }}</span>
                                        </a>

                                        <a class="social-media-login-btn manual-login-btn d-none" href="javascript:">
                                            <img alt=""
                                                src="{{ theme_asset(path: 'public/assets/front-end/img/icons/otp-login-icon.svg') }}">
                                            <span class="text">{{ translate('Manual_Login') }}</span>
                                        </a>
                                    @endif
                                </div>
                                @if ($multiColumn)
                                    @include('web-views.customer-views.auth.partials._sign-up-instruction')
                                @endif
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script')
    @php($recaptcha = getWebConfig(name: 'recaptcha'))
    @if ($web_config['firebase_otp_verification_status'])
        <script>
            $('.or-sign-in-with').css('width', $('.or-sign-in-with-row').height())
        </script>
    @endif
@endpush
