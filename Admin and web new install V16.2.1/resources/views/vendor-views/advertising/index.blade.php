@extends('layouts.vendor.app')
@section('title', translate('Sponsored_Products'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{ translate('Sponsored_Products') }}
            </h2>
            <p class="text-muted mb-0 fs-12">
                {{ translate('pay_to_have_one_of_your_products_shown_in_the_sponsored_section_on_the_homepage') }}
            </p>
        </div>

        @if(!$programEnabled)
            <div class="alert alert-warning">{{ translate('the_sponsored_product_program_is_currently_unavailable') }}</div>
        @else
            <div class="row g-3 mb-4">
                <div class="col-md-4 col-6">
                    <div class="card card-body">
                        <div class="fs-12 text-muted text-uppercase">{{ translate('price_per_day') }}</div>
                        <div class="fs-20 fw-bold">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $pricePerDay)) }}</div>
                    </div>
                </div>
                <div class="col-md-4 col-6">
                    <div class="card card-body">
                        <div class="fs-12 text-muted text-uppercase">{{ translate('slots_in_use') }}</div>
                        <div class="fs-20 fw-bold">{{ $activeSlotCount }} / {{ $maxActiveSlots > 0 ? $maxActiveSlots : translate('unlimited') }}</div>
                    </div>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-body">
                    <h4 class="mb-3">{{ translate('purchase_a_placement') }}</h4>
                    @if($products->count() == 0)
                        <p class="text-muted mb-0">{{ translate('you_have_no_active_products_to_advertise') }}</p>
                    @else
                        <form action="{{ route('vendor.advertising.purchase') }}" method="post" class="row g-3">
                            @csrf
                            <div class="col-md-5">
                                <label class="form-label">{{ translate('product') }}</label>
                                <select name="product_id" class="form-control" required>
                                    <option value="">{{ translate('select_a_product') }}</option>
                                    @foreach($products as $product)
                                        <option value="{{ $product->id }}">{{ $product->name }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">{{ translate('duration_days') }}</label>
                                <input type="number" name="days" class="form-control" min="1" max="60" value="7" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">{{ translate('payment_method') }}</label>
                                <select name="payment_method" class="form-control" required>
                                    @php($gateways = function_exists('payment_gateways') ? payment_gateways() : collect())
                                    @foreach($gateways as $gateway)
                                        <option value="{{ $gateway->key_name }}">{{ ucwords(str_replace('_', ' ', $gateway->key_name)) }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary">{{ translate('pay_and_activate') }}</button>
                            </div>
                        </form>
                    @endif
                </div>
            </div>
        @endif

        <div class="card">
            <div class="card-body">
                <h4 class="mb-3">{{ translate('your_placements') }}</h4>
                <div class="table-responsive">
                    <table class="table table-hover table-borderless align-middle">
                        <thead class="text-capitalize">
                            <tr>
                                <th>{{translate('product')}}</th>
                                <th>{{translate('days')}}</th>
                                <th>{{translate('amount_paid')}}</th>
                                <th>{{translate('starts')}}</th>
                                <th>{{translate('ends')}}</th>
                                <th>{{translate('status')}}</th>
                            </tr>
                        </thead>
                        <tbody>
                        @forelse($placements as $placement)
                            <tr>
                                <td>{{ $placement->product?->name }}</td>
                                <td>{{ $placement->days }}</td>
                                <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $placement->amount_paid)) }}</td>
                                <td>{{ $placement->start_at?->format('d M Y') ?? '-' }}</td>
                                <td>{{ $placement->end_at?->format('d M Y') ?? '-' }}</td>
                                <td>
                                    @if($placement->status == 'active')
                                        <span class="badge bg-soft-success text-success">{{ translate('active') }}</span>
                                    @elseif($placement->status == 'expired')
                                        <span class="badge bg-soft-secondary text-dark">{{ translate('expired') }}</span>
                                    @elseif($placement->status == 'failed')
                                        <span class="badge bg-soft-danger text-danger">{{ translate('failed') }}</span>
                                    @else
                                        <span class="badge bg-soft-warning text-warning">{{ translate('pending') }}</span>
                                    @endif
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">{{ translate('no_placements_yet') }}</td>
                            </tr>
                        @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
@endsection
