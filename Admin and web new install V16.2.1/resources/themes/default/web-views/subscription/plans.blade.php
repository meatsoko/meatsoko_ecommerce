@extends('layouts.front-end.app')

@section('title', translate('Subscription_Plans'))

@section('content')
    <div class="container py-2 py-md-4">
        <h1 class="fs-24 fw-bold mb-4">{{ translate('Subscription_Boxes') }}</h1>

        @if($plans->count() == 0)
            <p class="text-muted">{{ translate('no_subscription_plans_available_right_now') }}</p>
        @endif

        <div class="row g-4">
            @foreach($plans as $plan)
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100">
                        <img src="{{ getStorageImages(path: $plan->image_full_url, type: 'subscription-plan') }}" class="card-img-top" alt="{{ $plan->title }}">
                        <div class="card-body d-flex flex-column">
                            <h5 class="card-title">{{ $plan->title }}</h5>
                            <p class="text-muted text-capitalize mb-1">{{ translate('billed') }} {{ translate($plan->cadence) }}</p>
                            <p class="fs-20 fw-bold mb-2">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $plan->price)) }}</p>
                            <ul class="list-unstyled mb-3 fs-13 text-muted">
                                @foreach($plan->products as $planProduct)
                                    <li>&bull; {{ $planProduct->product->name ?? '' }} &times; {{ $planProduct->quantity }}</li>
                                @endforeach
                            </ul>

                            @auth('customer')
                                <button type="button" class="btn btn--primary mt-auto" data-bs-toggle="modal" data-bs-target="#subscribe-modal-{{ $plan->id }}">
                                    {{ translate('subscribe') }}
                                </button>

                                <div class="modal fade" id="subscribe-modal-{{ $plan->id }}" tabindex="-1">
                                    <div class="modal-dialog modal-dialog-centered">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">{{ translate('subscribe_to') }} {{ $plan->title }}</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <form action="{{ route('customer.subscriptions.subscribe', $plan->id) }}" method="post">
                                                @csrf
                                                <div class="modal-body">
                                                    <div class="mb-3">
                                                        <label class="form-label">{{ translate('shipping_address') }}</label>
                                                        <select name="shipping_address_id" class="form-select" required>
                                                            @forelse($addresses as $address)
                                                                <option value="{{ $address->id }}">{{ $address->address }}</option>
                                                            @empty
                                                                <option value="" disabled selected>{{ translate('no_saved_addresses_add_one_first') }}</option>
                                                            @endforelse
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">{{ translate('payment_method') }}</label>
                                                        <select name="payment_method" class="form-select subscription-payment-method" data-plan="{{ $plan->id }}" required>
                                                            <option value="wallet">{{ translate('wallet') }}</option>
                                                            <option value="mpesa">{{ translate('mpesa') }}</option>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3 d-none" id="subscription-phone-wrap-{{ $plan->id }}">
                                                        <label class="form-label">{{ translate('mpesa_phone_number') }}</label>
                                                        <input type="text" name="phone" class="form-control" placeholder="07xxxxxxxx">
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">{{ translate('cancel') }}</button>
                                                    <button type="submit" class="btn btn--primary">{{ translate('confirm_subscription') }}</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            @else
                                <a href="{{ route('customer.auth.login') }}" class="btn btn--primary mt-auto">{{ translate('login_to_subscribe') }}</a>
                            @endauth
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
@endsection

@push('script')
    <script>
        document.querySelectorAll('.subscription-payment-method').forEach(function (select) {
            select.addEventListener('change', function () {
                var wrap = document.getElementById('subscription-phone-wrap-' + this.dataset.plan);
                wrap.classList.toggle('d-none', this.value !== 'mpesa');
            });
        });
    </script>
@endpush
