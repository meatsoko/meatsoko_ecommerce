@extends('layouts.admin.app')

@section('title', translate('Affiliate_Details'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{ $affiliate->f_name }} {{ $affiliate->l_name }}
            </h2>
            <a href="{{ route('admin.affiliate.list') }}" class="btn btn-outline-secondary">
                {{translate('back_to_list')}}
            </a>
        </div>

        <div class="row">
            <div class="col-lg-4 mb-3">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="text-capitalize d-flex align-items-center justify-content-between gap-2 border-bottom pb-3 mb-3">
                            <h3 class="h3 mb-0">{{translate('affiliate_info')}}</h3>
                            @if($affiliate->status == 'approved')
                                <span class="badge bg-soft-success text-success">{{ translate('approved') }}</span>
                            @elseif($affiliate->status == 'suspended')
                                <span class="badge bg-soft-danger text-danger">{{ translate('suspended') }}</span>
                            @else
                                <span class="badge bg-soft-warning text-warning">{{ translate('pending') }}</span>
                            @endif
                        </div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('email')}}:</h5><h5 class="mb-0">{{ $affiliate->email }}</h5></div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('phone')}}:</h5><h5 class="mb-0">{{ $affiliate->phone ?: '-' }}</h5></div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('code')}}:</h5><h5 class="mb-0"><code>{{ $affiliate->affiliate_code }}</code></h5></div>
                        <div class="d-flex gap-1 flex-wrap"><h5 class="mb-0">{{translate('joined')}}:</h5><h5 class="mb-0">{{ $affiliate->created_at?->format('d M Y') }}</h5></div>
                    </div>
                </div>
            </div>
            <div class="col-lg-8 mb-3">
                <div class="row g-3 h-100">
                    <div class="col-md-4 col-6">
                        <div class="card h-100"><div class="card-body text-center">
                            <h3 class="mb-1">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $affiliate->wallet->total_earning ?? 0)) }}</h3>
                            <span class="text-muted fs-12 text-uppercase">{{translate('total_earned')}}</span>
                        </div></div>
                    </div>
                    <div class="col-md-4 col-6">
                        <div class="card h-100"><div class="card-body text-center">
                            <h3 class="mb-1">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $affiliate->wallet->pending_withdraw ?? 0)) }}</h3>
                            <span class="text-muted fs-12 text-uppercase">{{translate('pending_withdraw')}}</span>
                        </div></div>
                    </div>
                    <div class="col-md-4 col-6">
                        <div class="card h-100"><div class="card-body text-center">
                            <h3 class="mb-1">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $affiliate->wallet->withdrawn ?? 0)) }}</h3>
                            <span class="text-muted fs-12 text-uppercase">{{translate('withdrawn')}}</span>
                        </div></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body d-flex flex-column gap-20">
                        <h3 class="mb-0">
                            {{ translate('referred_customers_&_orders') }}
                            <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $orders->total() }}</span>
                        </h3>
                        <div class="table-responsive">
                            <table class="table table-hover table-borderless align-middle">
                                <thead class="text-capitalize">
                                <tr>
                                    <th>{{translate('order')}}</th>
                                    <th>{{translate('date')}}</th>
                                    <th>{{translate('customer')}}</th>
                                    <th>{{translate('order_amount')}}</th>
                                    <th>{{translate('order_status')}}</th>
                                    <th>{{translate('commission')}}</th>
                                </tr>
                                </thead>
                                <tbody>
                                @forelse($orders as $order)
                                    <tr>
                                        <td>
                                            <a href="{{ route('admin.orders.details', ['id' => $order->id]) }}">#{{ $order->id }}</a>
                                        </td>
                                        <td>{{ $order->created_at?->format('d M Y') }}</td>
                                        <td>
                                            @if ($order->is_guest)
                                                <strong class="text-dark">{{ translate('guest_customer') }}</strong>
                                            @elseif($order->customer_id == 0)
                                                <strong class="text-dark">{{ translate('Walk-In-Customer') }}</strong>
                                            @else
                                                @if ($order->customer)
                                                    <a class="text-capitalize text-dark" href="{{ route('admin.customer.view', ['user_id' => $order->customer->id]) }}">
                                                        {{ $order->customer->f_name }} {{ $order->customer->l_name }}
                                                    </a>
                                                @else
                                                    <span class="badge badge-danger text-bg-danger">{{ translate('customer_not_found') }}</span>
                                                @endif
                                            @endif
                                        </td>
                                        <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $order->order_amount)) }}</td>
                                        <td class="text-capitalize">{{ translate($order->order_status) }}</td>
                                        <td>
                                            @if($order->affiliateCommission)
                                                <span class="fw-semibold">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $order->affiliateCommission->amount)) }}</span>
                                            @else
                                                <span class="text-muted fs-12">{{ translate('pending_delivery') }}</span>
                                            @endif
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">{{ translate('no_referred_orders_yet') }}</td>
                                    </tr>
                                @endforelse
                                </tbody>
                            </table>
                            <table class="mt-4">
                                <tfoot>
                                {!! $orders->links() !!}
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
