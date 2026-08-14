@extends('layouts.affiliate.app')
@section('title', translate('Withdrawals'))
@section('content')
    <div class="row g-3 mb-4">
        <div class="col-md-4 col-6">
            <div class="stat-box">
                <div class="value">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $wallet->total_earning ?? 0)) }}</div>
                <div class="label">{{ translate('available_balance') }}</div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="stat-box">
                <div class="value">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $wallet->pending_withdraw ?? 0)) }}</div>
                <div class="label">{{ translate('pending_withdraw') }}</div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="stat-box">
                <div class="value">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $wallet->withdrawn ?? 0)) }}</div>
                <div class="label">{{ translate('withdrawn') }}</div>
            </div>
        </div>
    </div>

    <div class="affiliate-card p-4 mb-4">
        <h5 class="mb-3">{{ translate('request_a_withdrawal') }}</h5>
        <form action="{{ route('affiliate.withdraw.store') }}" method="post" class="row g-3 align-items-end">
            @csrf
            <div class="col-sm-4">
                <label class="form-label small">{{ translate('amount') }}</label>
                <input type="number" step="0.01" min="1" max="{{ $wallet->total_earning ?? 0 }}"
                       name="amount" class="form-control" required>
            </div>
            <div class="col-sm-5">
                <label class="form-label small">{{ translate('note') }} ({{ translate('optional') }})</label>
                <input type="text" name="note" class="form-control" maxlength="255">
            </div>
            <div class="col-sm-3">
                <button type="submit" class="btn btn-primary w-100">{{ translate('submit_request') }}</button>
            </div>
        </form>
    </div>

    <div class="affiliate-card p-4">
        <h5 class="mb-3">{{ translate('withdraw_history') }}</h5>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                <tr class="text-muted small text-uppercase">
                    <th>{{ translate('date') }}</th>
                    <th>{{ translate('amount') }}</th>
                    <th>{{ translate('note') }}</th>
                    <th>{{ translate('status') }}</th>
                </tr>
                </thead>
                <tbody>
                @forelse($withdrawRequests as $withdrawRequest)
                    <tr>
                        <td>{{ $withdrawRequest->created_at?->format('d M Y') }}</td>
                        <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $withdrawRequest->amount)) }}</td>
                        <td>{{ $withdrawRequest->transaction_note ?: '-' }}</td>
                        <td>
                            @if($withdrawRequest->approved == 1)
                                <span class="badge bg-success">{{ translate('approved') }}</span>
                            @elseif($withdrawRequest->approved == 2)
                                <span class="badge bg-danger">{{ translate('denied') }}</span>
                            @else
                                <span class="badge bg-warning text-dark">{{ translate('pending') }}</span>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="text-center text-muted py-4">{{ translate('no_withdraw_request_found') }}</td>
                    </tr>
                @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection
