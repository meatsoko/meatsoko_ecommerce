@extends('layouts.admin.app')

@section('title', translate('Subscribers'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Subscribers')}}
            </h2>
        </div>

        <div class="card">
            <div class="card-body">
                <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
                    <h3 class="text-capitalize mb-0">
                        {{ translate('all_subscriptions')}}
                        <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $subscriptions->total() }}</span>
                    </h3>
                    <div class="d-flex flex-wrap gap-3 align-items-center">
                        <form action="{{ url()->current() }}" method="get" class="flex-grow-1 max-w-300 min-w-100-mobile">
                            <div class="input-group">
                                <input type="search" name="searchValue" class="form-control"
                                       placeholder="{{translate('search_by_customer_name_email_or_phone')}}"
                                       value="{{ request('searchValue') }}">
                                <div class="input-group-append search-submit">
                                    <button type="submit"><i class="fi fi-rr-search"></i></button>
                                </div>
                            </div>
                        </form>
                        <div class="select-wrapper">
                            <select name="status" class="form-select min-w-120" onchange="location.href='{{ url()->current() }}?status='+this.value">
                                <option value="" {{ request('status') ? '' : 'selected' }}>{{translate('all')}}</option>
                                <option value="active" {{request('status') == 'active' ? 'selected' : ''}}>{{translate('active')}}</option>
                                <option value="paused" {{request('status') == 'paused' ? 'selected' : ''}}>{{translate('paused')}}</option>
                                <option value="cancelled" {{request('status') == 'cancelled' ? 'selected' : ''}}>{{translate('cancelled')}}</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover table-borderless align-middle">
                        <thead class="text-capitalize">
                        <tr>
                            <th>{{translate('customer')}}</th>
                            <th>{{translate('plan')}}</th>
                            <th>{{translate('payment_method')}}</th>
                            <th>{{translate('next_billing_date')}}</th>
                            <th>{{translate('status')}}</th>
                            <th class="text-center">{{translate('action')}}</th>
                        </tr>
                        </thead>
                        <tbody>
                        @foreach($subscriptions as $subscription)
                            <tr>
                                <td>
                                    @if($subscription->customer)
                                        {{ $subscription->customer->f_name }} {{ $subscription->customer->l_name }}
                                    @else
                                        <span class="text-muted">{{translate('not_found')}}</span>
                                    @endif
                                </td>
                                <td>{{ $subscription->plan->title ?? '-' }}</td>
                                <td class="text-capitalize">{{ translate($subscription->payment_method) }}</td>
                                <td>{{ $subscription->next_billing_date?->format('d M Y') }}</td>
                                <td>
                                    @if($subscription->status == 'active')
                                        <span class="badge bg-soft-success text-success">{{ translate('active') }}</span>
                                    @elseif($subscription->status == 'paused')
                                        <span class="badge bg-soft-warning text-warning">{{ translate('paused') }}</span>
                                    @else
                                        <span class="badge bg-soft-danger text-danger">{{ translate('cancelled') }}</span>
                                    @endif
                                </td>
                                <td class="text-center">
                                    <a href="{{ route('admin.subscription.subscribers.view', $subscription->id) }}"
                                       class="btn btn-outline-info icon-btn" title="{{translate('Details')}}">
                                        <i class="fi fi-rr-eye"></i>
                                    </a>
                                </td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                    <table class="mt-4">
                        <tfoot>
                        {!! $subscriptions->links() !!}
                        </tfoot>
                    </table>
                </div>
                @if(count($subscriptions) <= 0)
                    @include('layouts.admin.partials._empty-state',['text'=>'no_data_found'],['image'=>'default'])
                @endif
            </div>
        </div>
    </div>
@endsection
