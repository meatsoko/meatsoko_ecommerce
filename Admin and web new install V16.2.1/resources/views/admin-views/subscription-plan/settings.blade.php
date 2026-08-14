@extends('layouts.admin.app')

@section('title', translate('Subscription_Settings'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Subscription_Settings')}}
            </h2>
        </div>

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body">
                        <form action="{{ route('admin.subscription-plan.settings.update') }}" method="post">
                            @csrf
                            <div class="d-flex justify-content-between align-items-start gap-3 border rounded p-3 mb-3">
                                <span>
                                    <h5 class="fw-medium text-dark fs-14 mb-1">{{ translate('Subscription_Program') }}</h5>
                                    <p class="mb-0 fs-12">{{ translate('when_enabled_customers_can_subscribe_to_recurring_boxes_and_be_billed_automatically') }}</p>
                                </span>
                                <label class="switcher" for="subscription-program-status">
                                    <input class="switcher_input" type="checkbox" value="1" name="subscription_program_status"
                                           id="subscription-program-status" {{ $subscriptionProgramStatus == 1 ? 'checked' : '' }}>
                                    <span class="switcher_control"></span>
                                </label>
                            </div>

                            <button type="submit" class="btn btn-primary">{{ translate('save') }}</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
