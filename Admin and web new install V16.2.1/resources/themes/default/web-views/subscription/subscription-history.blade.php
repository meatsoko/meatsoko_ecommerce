@extends('layouts.front-end.app')

@section('title', translate('Subscription_History'))

@section('content')
    <div class="container py-2 py-md-4 p-0 p-md-2 user-profile-container px-5px">
        <div class="row">
            @include('web-views.partials._profile-aside')

            <section class="col-lg-9 __customer-profile px-0">
                <div class="card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="font-bold mb-0 fs-16">{{ $subscription->plan->title ?? '-' }} &mdash; {{ translate('charge_history') }}</h5>
                            <a href="{{ route('customer.subscriptions.index') }}" class="btn btn-sm btn-outline-secondary">{{ translate('back') }}</a>
                        </div>

                        <div class="table-responsive">
                            <table class="table align-middle">
                                <thead>
                                <tr class="text-muted small text-uppercase">
                                    <th>{{ translate('date') }}</th>
                                    <th>{{ translate('amount') }}</th>
                                    <th>{{ translate('status') }}</th>
                                    <th>{{ translate('order') }}</th>
                                </tr>
                                </thead>
                                <tbody>
                                @forelse($charges as $charge)
                                    <tr>
                                        <td>{{ $charge->attempted_at?->format('d M Y H:i') }}</td>
                                        <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $charge->amount)) }}</td>
                                        <td>
                                            @if($charge->status == 'success')
                                                <span class="badge bg-success">{{ translate('success') }}</span>
                                            @elseif($charge->status == 'failed')
                                                <span class="badge bg-danger">{{ translate('failed') }}</span>
                                            @else
                                                <span class="badge bg-warning text-dark">{{ translate('pending') }}</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($charge->order_id)
                                                <a href="{{ route('account-order-details', ['id' => $charge->order_id]) }}">#{{ $charge->order_id }}</a>
                                            @else
                                                -
                                            @endif
                                        </td>
                                    </tr>
                                @empty
                                    <tr><td colspan="4" class="text-center text-muted py-4">{{ translate('no_charges_yet') }}</td></tr>
                                @endforelse
                                </tbody>
                            </table>
                            <div class="d-flex justify-content-end">
                                {{ $charges->links() }}
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>
@endsection
