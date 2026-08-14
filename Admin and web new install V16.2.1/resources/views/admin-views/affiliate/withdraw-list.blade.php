@extends('layouts.admin.app')

@section('title', translate('Affiliate_Withdrawals'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Affiliate_Withdrawals')}}
            </h2>
        </div>

        <div class="card">
            <div class="card-body">
                <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
                    <h3 class="text-capitalize mb-0">
                        {{ translate('withdraw_request_table')}}
                        <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $withdrawRequests->total() }}</span>
                    </h3>
                    <div class="d-flex flex-wrap justify-content-start justify-content-md-end align-items-center gap-3 min-w-100-mobile">
                        <form action="{{ url()->current() }}" method="get" class="flex-grow-1 max-w-300 min-w-100-mobile">
                            <div class="input-group">
                                <input type="search" name="searchValue" class="form-control"
                                       placeholder="{{translate('search_by_name_email_or_code')}}"
                                       value="{{ request('searchValue') }}">
                                <div class="input-group-append search-submit">
                                    <button type="submit"><i class="fi fi-rr-search"></i></button>
                                </div>
                            </div>
                        </form>
                        <div class="select-wrapper">
                            <select name="status" class="form-select min-w-120" onchange="location.href='{{ url()->current() }}?status='+this.value">
                                <option value="" {{ request('status') ? '' : 'selected' }}>{{translate('all')}}</option>
                                <option value="pending" {{request('status') == 'pending' ? 'selected' : ''}}>{{translate('pending')}}</option>
                                <option value="approved" {{request('status') == 'approved' ? 'selected' : ''}}>{{translate('approved')}}</option>
                                <option value="denied" {{request('status') == 'denied' ? 'selected' : ''}}>{{translate('denied')}}</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover table-borderless align-middle">
                        <thead class="text-capitalize">
                        <tr>
                            <th>{{translate('affiliate')}}</th>
                            <th>{{translate('amount')}}</th>
                            <th>{{translate('note')}}</th>
                            <th>{{translate('request_time')}}</th>
                            <th class="text-center">{{translate('status')}}</th>
                            <th class="text-center">{{translate('action')}}</th>
                        </tr>
                        </thead>
                        <tbody>
                        @foreach($withdrawRequests as $withdrawRequest)
                            <tr>
                                <td>
                                    @if($withdrawRequest->affiliate)
                                        {{ $withdrawRequest->affiliate->f_name }} {{ $withdrawRequest->affiliate->l_name }}
                                    @else
                                        <span class="text-muted">{{translate('not_found')}}</span>
                                    @endif
                                </td>
                                <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $withdrawRequest->amount)) }}</td>
                                <td>{{ $withdrawRequest->transaction_note ?: '-' }}</td>
                                <td>{{ $withdrawRequest->created_at }}</td>
                                <td class="text-center">
                                    @if($withdrawRequest->approved == 0)
                                        <span class="badge bg-soft-warning text-warning">{{ translate('pending') }}</span>
                                    @elseif($withdrawRequest->approved == 1)
                                        <span class="badge bg-soft-success text-success">{{ translate('approved') }}</span>
                                    @else
                                        <span class="badge bg-soft-danger text-danger">{{ translate('denied') }}</span>
                                    @endif
                                </td>
                                <td class="text-center">
                                    <a href="{{ route('admin.affiliate.withdraw-view', $withdrawRequest->id) }}"
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
                        {!! $withdrawRequests->links() !!}
                        </tfoot>
                    </table>
                </div>
                @if(count($withdrawRequests) <= 0)
                    @include('layouts.admin.partials._empty-state',['text'=>'no_withdraw_request_found'],['image'=>'default'])
                @endif
            </div>
        </div>
    </div>
@endsection
