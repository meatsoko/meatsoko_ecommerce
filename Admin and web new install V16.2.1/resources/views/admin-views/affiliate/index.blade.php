@extends('layouts.admin.app')

@section('title', translate('Affiliates'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Affiliates')}}
            </h2>
            <a href="{{ route('admin.affiliate.settings') }}" class="btn btn-outline-primary">
                {{translate('Affiliate_Settings')}}
            </a>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body d-flex flex-column gap-20">
                        <div class="d-flex justify-content-between align-items-center gap-20 flex-wrap">
                            <h3 class="mb-0">
                                {{ translate('all_affiliates')}}
                                <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $affiliates->total() }}</span>
                            </h3>
                            <form action="{{ url()->current() }}" method="get" class="flex-grow-1 max-w-300 min-w-100-mobile">
                                <div class="input-group">
                                    <input type="search" name="searchValue" class="form-control"
                                           placeholder="{{translate('search_by_name_email_or_code')}}"
                                           value="{{ $searchValue }}">
                                    <div class="input-group-append search-submit">
                                        <button type="submit"><i class="fi fi-rr-search"></i></button>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-hover table-borderless align-middle">
                                <thead class="text-capitalize">
                                    <tr>
                                        <th>{{translate('name')}}</th>
                                        <th>{{translate('email')}}</th>
                                        <th>{{translate('code')}}</th>
                                        <th>{{translate('total_earned')}}</th>
                                        <th>{{translate('status')}}</th>
                                        <th class="text-center">{{translate('action')}}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                @foreach($affiliates as $affiliate)
                                    <tr>
                                        <td>{{ $affiliate->f_name }} {{ $affiliate->l_name }}</td>
                                        <td>{{ $affiliate->email }}</td>
                                        <td><code>{{ $affiliate->affiliate_code }}</code></td>
                                        <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $affiliate->wallet->total_earning ?? 0)) }}</td>
                                        <td>
                                            @if($affiliate->status == 'approved')
                                                <span class="badge bg-soft-success text-success">{{ translate('approved') }}</span>
                                            @elseif($affiliate->status == 'suspended')
                                                <span class="badge bg-soft-danger text-danger">{{ translate('suspended') }}</span>
                                            @else
                                                <span class="badge bg-soft-warning text-warning">{{ translate('pending') }}</span>
                                            @endif
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                @if($affiliate->status != 'approved')
                                                    <form action="{{ route('admin.affiliate.status-update', $affiliate->id) }}" method="post">
                                                        @csrf
                                                        <input type="hidden" name="status" value="approved">
                                                        <button type="submit" class="btn btn-outline-success btn-sm">{{ translate('approve') }}</button>
                                                    </form>
                                                @endif
                                                @if($affiliate->status != 'suspended')
                                                    <form action="{{ route('admin.affiliate.status-update', $affiliate->id) }}" method="post">
                                                        @csrf
                                                        <input type="hidden" name="status" value="suspended">
                                                        <button type="submit" class="btn btn-outline-danger btn-sm">{{ translate('suspend') }}</button>
                                                    </form>
                                                @endif
                                            </div>
                                        </td>
                                    </tr>
                                @endforeach
                                </tbody>
                            </table>
                            <table class="mt-4">
                                <tfoot>
                                {!! $affiliates->links() !!}
                                </tfoot>
                            </table>
                        </div>
                        @if(count($affiliates) <= 0)
                            @include('layouts.admin.partials._empty-state',['text'=>'no_data_found'],['image'=>'default'])
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
