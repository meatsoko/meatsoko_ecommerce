@extends('layouts.admin.app')

@section('title', translate('Subscription_Details'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Subscription_Details')}}
            </h2>
            <a href="{{ route('admin.subscription.subscribers') }}" class="btn btn-outline-secondary">{{translate('back_to_list')}}</a>
        </div>

        <div class="row">
            <div class="col-lg-6 mb-3">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="text-capitalize d-flex align-items-center justify-content-between gap-2 border-bottom pb-3 mb-3">
                            <h3 class="h3 mb-0">{{translate('subscription_info')}}</h3>
                            @if($subscription->status == 'active')
                                <span class="badge bg-soft-success text-success">{{ translate('active') }}</span>
                            @elseif($subscription->status == 'paused')
                                <span class="badge bg-soft-warning text-warning">{{ translate('paused') }}</span>
                            @else
                                <span class="badge bg-soft-danger text-danger">{{ translate('cancelled') }}</span>
                            @endif
                        </div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('customer')}}:</h5><h5 class="mb-0">{{ $subscription->customer->f_name ?? '' }} {{ $subscription->customer->l_name ?? '' }}</h5></div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('plan')}}:</h5><h5 class="mb-0">{{ $subscription->plan->title ?? '-' }}</h5></div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('price')}}:</h5><h5 class="mb-0">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $subscription->plan->price ?? 0)) }}</h5></div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('payment_method')}}:</h5><h5 class="mb-0 text-capitalize">{{ translate($subscription->payment_method) }}</h5></div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('next_billing_date')}}:</h5><h5 class="mb-0">{{ $subscription->next_billing_date?->format('d M Y') }}</h5></div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('failed_attempts')}}:</h5><h5 class="mb-0">{{ $subscription->failed_attempts }}</h5></div>

                        <form action="{{ route('admin.subscription.subscribers.status-update', $subscription->id) }}" method="post" class="mt-3 d-flex gap-2">
                            @csrf
                            <select name="status" class="form-select max-w-200">
                                <option value="active" {{ $subscription->status == 'active' ? 'selected' : '' }}>{{translate('active')}}</option>
                                <option value="paused" {{ $subscription->status == 'paused' ? 'selected' : '' }}>{{translate('paused')}}</option>
                                <option value="cancelled" {{ $subscription->status == 'cancelled' ? 'selected' : '' }}>{{translate('cancelled')}}</option>
                            </select>
                            <button type="submit" class="btn btn-primary">{{translate('update_status')}}</button>
                        </form>

                        @if($subscription->status != 'cancelled')
                            <form action="{{ route('admin.subscription.subscribers.bill-now', $subscription->id) }}" method="post" class="mt-2"
                                  onsubmit="return confirm('{{ translate('charge_this_subscription_right_now') }}?');">
                                @csrf
                                <button type="submit" class="btn btn-outline-primary btn-sm">{{ translate('bill_now') }}</button>
                            </form>
                        @endif
                    </div>
                </div>
            </div>
            <div class="col-lg-6 mb-3">
                <div class="card h-100">
                    <div class="card-body">
                        <h3 class="h3 mb-3">{{translate('box_contents')}}</h3>
                        <ul class="list-unstyled mb-0">
                            @foreach($subscription->plan->products ?? [] as $planProduct)
                                <li class="d-flex justify-content-between border-bottom py-2">
                                    <span>{{ $planProduct->product->name ?? translate('product_not_found') }}</span>
                                    <span class="text-muted">x{{ $planProduct->quantity }}</span>
                                </li>
                            @endforeach
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <h3 class="mb-3">
                            {{ translate('charge_history') }}
                            <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $charges->total() }}</span>
                        </h3>
                        <div class="table-responsive">
                            <table class="table table-hover table-borderless align-middle">
                                <thead class="text-capitalize">
                                <tr>
                                    <th>{{translate('date')}}</th>
                                    <th>{{translate('amount')}}</th>
                                    <th>{{translate('payment_method')}}</th>
                                    <th>{{translate('status')}}</th>
                                    <th>{{translate('order')}}</th>
                                    <th>{{translate('failure_reason')}}</th>
                                </tr>
                                </thead>
                                <tbody>
                                @forelse($charges as $charge)
                                    <tr>
                                        <td>{{ $charge->attempted_at?->format('d M Y H:i') }}</td>
                                        <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $charge->amount)) }}</td>
                                        <td class="text-capitalize">{{ translate($charge->payment_method) }}</td>
                                        <td>
                                            @if($charge->status == 'success')
                                                <span class="badge bg-soft-success text-success">{{ translate('success') }}</span>
                                            @elseif($charge->status == 'failed')
                                                <span class="badge bg-soft-danger text-danger">{{ translate('failed') }}</span>
                                            @else
                                                <span class="badge bg-soft-warning text-warning">{{ translate('pending') }}</span>
                                            @endif
                                        </td>
                                        <td>
                                            @if($charge->order_id)
                                                <a href="{{ route('admin.orders.details', ['id' => $charge->order_id]) }}">#{{ $charge->order_id }}</a>
                                            @else
                                                -
                                            @endif
                                        </td>
                                        <td>{{ $charge->failure_reason ?: '-' }}</td>
                                    </tr>
                                @empty
                                    <tr><td colspan="6" class="text-center text-muted py-4">{{ translate('no_charges_yet') }}</td></tr>
                                @endforelse
                                </tbody>
                            </table>
                            <table class="mt-4">
                                <tfoot>
                                {!! $charges->links() !!}
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
