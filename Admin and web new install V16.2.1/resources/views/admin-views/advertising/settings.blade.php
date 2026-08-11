@extends('layouts.admin.app')

@section('title', translate('Advertising_Settings'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Advertising_Settings')}}
            </h2>
            <a href="{{ route('admin.advertising.list') }}" class="btn btn-outline-primary">
                {{translate('view_placements')}}
            </a>
        </div>

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body">
                        <p class="text-muted fs-12">
                            {{ translate('vendors_pay_to_have_one_of_their_own_products_shown_in_the_sponsored_section_on_the_homepage_for_a_chosen_number_of_days') }}
                        </p>
                        <form action="{{ route('admin.advertising.settings.update') }}" method="post">
                            @csrf
                            <div class="d-flex justify-content-between align-items-start gap-3 border rounded p-3 mb-3">
                                <span>
                                    <h5 class="fw-medium text-dark fs-14 mb-1">{{ translate('Sponsored_Product_Program') }}</h5>
                                    <p class="mb-0 fs-12">{{ translate('when_disabled_the_sponsored_section_is_hidden_and_vendors_cannot_purchase_new_placements') }}</p>
                                </span>
                                <label class="switcher" for="ad-placement-status">
                                    <input class="switcher_input" type="checkbox" value="1" name="ad_placement_status"
                                           id="ad-placement-status" {{ $adPlacementStatus == 1 ? 'checked' : '' }}>
                                    <span class="switcher_control"></span>
                                </label>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">{{ translate('price_per_day') }}
                                            ({{ getCurrencySymbol(currencyCode: getCurrencyCode()) }})</label>
                                        <input type="number" step="0.01" min="0" name="ad_placement_price_per_day"
                                               class="form-control" value="{{ $adPlacementPricePerDay ?? 0 }}" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label">{{ translate('max_concurrent_active_slots') }}
                                            <span class="tooltip-icon" data-bs-toggle="tooltip"
                                                  data-bs-title="{{ translate('purchases_are_blocked_once_this_many_placements_are_active_at_once_so_a_vendor_is_never_charged_for_a_slot_that_does_not_exist') }}">
                                                <i class="fi fi-sr-info"></i>
                                            </span>
                                        </label>
                                        <input type="number" min="1" max="50" name="ad_placement_max_active_slots"
                                               class="form-control" value="{{ $adPlacementMaxActiveSlots ?? 10 }}" required>
                                    </div>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary mt-3">{{ translate('save') }}</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
