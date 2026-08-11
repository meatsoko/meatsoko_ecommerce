@extends('layouts.affiliate.app')
@section('title', translate('Dashboard'))
@section('content')
    <div class="affiliate-card p-4 mb-4">
        <h5 class="mb-1">{{ translate('your_referral_link') }}</h5>
        <p class="text-muted small mb-3">{{ translate('share_this_link_anywhere_you_get_credit_for_any_purchase_made_within') }} 30 {{ translate('days_of_a_click') }}</p>
        <div class="input-group">
            <input type="text" id="affiliateLink" class="form-control" value="{{ $affiliateLink }}" readonly>
            <button class="btn btn-outline-secondary" type="button" onclick="navigator.clipboard.writeText(document.getElementById('affiliateLink').value)">
                {{ translate('copy') }}
            </button>
        </div>
        <p class="small text-muted mt-2 mb-0">{{ translate('your_code') }}: <code class="affiliate-code">{{ $affiliate->affiliate_code }}</code></p>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3 col-6">
            <div class="stat-box">
                <div class="value">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $wallet->total_earning ?? 0)) }}</div>
                <div class="label">{{ translate('total_earned') }}</div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-box">
                <div class="value">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $wallet->pending_withdraw ?? 0)) }}</div>
                <div class="label">{{ translate('pending_withdraw') }}</div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-box">
                <div class="value">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $wallet->withdrawn ?? 0)) }}</div>
                <div class="label">{{ translate('withdrawn') }}</div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-box">
                <div class="value">{{ $commissionRate }}%</div>
                <div class="label">{{ translate('commission_rate') }}</div>
            </div>
        </div>
    </div>

    <div class="affiliate-card p-4">
        <h5 class="mb-3">{{ translate('recent_commissions') }}</h5>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr class="text-muted small text-uppercase">
                    <th>{{ translate('date') }}</th>
                    <th>{{ translate('order') }}</th>
                    <th>{{ translate('order_amount') }}</th>
                    <th>{{ translate('rate') }}</th>
                    <th>{{ translate('commission') }}</th>
                </tr>
                </thead>
                <tbody>
                @forelse($commissions as $commission)
                    <tr>
                        <td>{{ $commission->created_at?->format('d M Y') }}</td>
                        <td>#{{ $commission->order_id }}</td>
                        <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $commission->order_amount)) }}</td>
                        <td>{{ $commission->commission_rate }}%</td>
                        <td class="fw-semibold">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $commission->amount)) }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="text-center text-muted py-4">{{ translate('no_commissions_earned_yet') }}</td>
                    </tr>
                @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection
