@extends('layouts.front-end.app')

@section('title', translate('my_Subscriptions'))

@section('content')
    <div class="container py-2 py-md-4 p-0 p-md-2 user-profile-container px-5px">
        <div class="row">
            @include('web-views.partials._profile-aside')

            <section class="col-lg-9 __customer-profile px-0">
                <div class="card">
                    <div class="card-body">
                        <h5 class="font-bold mb-3 fs-16">{{ translate('my_subscriptions') }}</h5>

                        @forelse($subscriptions as $subscription)
                            <div class="border rounded p-3 mb-3">
                                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                                    <div>
                                        <h6 class="mb-1">{{ $subscription->plan->title ?? '-' }}</h6>
                                        <p class="mb-1 text-muted fs-13">
                                            {{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $subscription->plan->price ?? 0)) }}
                                            &middot; {{ translate('billed') }} {{ translate($subscription->plan->cadence ?? '') }}
                                            &middot; {{ translate('paid_via') }} {{ translate($subscription->payment_method) }}
                                        </p>
                                        <p class="mb-0 fs-13">
                                            @if($subscription->status == 'active')
                                                <span class="badge bg-success">{{ translate('active') }}</span>
                                                &mdash; {{ translate('next_charge') }} {{ $subscription->next_billing_date?->format('d M Y') }}
                                            @elseif($subscription->status == 'paused')
                                                <span class="badge bg-warning text-dark">{{ translate('paused') }}</span>
                                            @else
                                                <span class="badge bg-danger">{{ translate('cancelled') }}</span>
                                            @endif
                                        </p>
                                    </div>
                                    <div class="d-flex gap-2 flex-wrap">
                                        <a href="{{ route('customer.subscriptions.history', $subscription->id) }}" class="btn btn-sm btn-outline-secondary">{{ translate('history') }}</a>
                                        @if($subscription->status == 'active')
                                            <form action="{{ route('customer.subscriptions.pause', $subscription->id) }}" method="post">
                                                @csrf
                                                <button type="submit" class="btn btn-sm btn-outline-warning">{{ translate('pause') }}</button>
                                            </form>
                                        @elseif($subscription->status == 'paused')
                                            <form action="{{ route('customer.subscriptions.resume', $subscription->id) }}" method="post">
                                                @csrf
                                                <button type="submit" class="btn btn-sm btn-outline-success">{{ translate('resume') }}</button>
                                            </form>
                                        @endif
                                        @if($subscription->status != 'cancelled')
                                            <form action="{{ route('customer.subscriptions.cancel', $subscription->id) }}" method="post" onsubmit="return confirm('{{ translate('are_you_sure_you_want_to_cancel_this_subscription') }}');">
                                                @csrf
                                                <button type="submit" class="btn btn-sm btn-outline-danger">{{ translate('cancel') }}</button>
                                            </form>
                                        @endif
                                    </div>
                                </div>
                            </div>
                        @empty
                            <p class="text-muted">{{ translate('you_have_no_subscriptions_yet') }}
                                <a href="{{ route('customer.subscriptions.plans') }}">{{ translate('browse_subscription_boxes') }}</a>
                            </p>
                        @endforelse
                    </div>
                </div>
            </section>
        </div>
    </div>
@endsection
