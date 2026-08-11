@extends('layouts.admin.app')

@section('title', translate('Affiliate_Settings'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Affiliate_Settings')}}
            </h2>
        </div>

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body">
                        <form action="{{ route('admin.affiliate.settings.update') }}" method="post">
                            @csrf
                            <div class="d-flex justify-content-between align-items-start gap-3 border rounded p-3 mb-3">
                                <span>
                                    <h5 class="fw-medium text-dark fs-14 mb-1">{{ translate('Affiliate_Program') }}</h5>
                                    <p class="mb-0 fs-12">{{ translate('when_enabled_marketing_affiliates_can_register_share_their_link_and_earn_commission_on_orders_they_bring_in') }}</p>
                                </span>
                                <label class="switcher" for="affiliate-program-status">
                                    <input class="switcher_input" type="checkbox" value="1" name="affiliate_program_status"
                                           id="affiliate-program-status" {{ $affiliateProgramStatus == 1 ? 'checked' : '' }}>
                                    <span class="switcher_control"></span>
                                </label>
                            </div>

                            <div class="form-group mb-3">
                                <label class="form-label">{{ translate('Commission_Rate') }} (%)</label>
                                <input type="number" step="0.01" min="0" max="100" name="affiliate_commission_rate"
                                       class="form-control" style="max-width: 220px;"
                                       value="{{ $affiliateCommissionRate ?? 0 }}" required>
                                <small class="text-muted">{{ translate('percentage_of_the_order_amount_minus_shipping_paid_to_the_affiliate_only_once_the_order_is_delivered') }}</small>
                            </div>

                            <button type="submit" class="btn btn-primary">{{ translate('save') }}</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
