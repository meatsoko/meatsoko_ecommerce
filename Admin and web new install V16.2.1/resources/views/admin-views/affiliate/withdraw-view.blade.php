@extends('layouts.admin.app')

@section('title', translate('Withdraw_information_View'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('withdraw')}}
            </h2>
        </div>
        <div class="row">
            <div class="col-md-8 mb-3">
                <div class="card h-100">
                    <div class="card-body text-start">
                        <div class="text-capitalize d-flex align-items-center justify-content-between gap-2 border-bottom pb-2 mb-4">
                            <h3 class="text-capitalize mb-0">{{translate('affiliate_withdraw_information')}}</h3>
                            <i class="fi fi-rr-wallet fs-3"></i>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-2 mb-md-0">
                                <div class="d-flex gap-1 flex-wrap">
                                    <h5 class="text-capitalize mb-0">{{translate('amount').':'.' '}}</h5>
                                    <h5 class="mb-0">{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $withdrawRequest->amount)) }}</h5>
                                </div>
                                <div class="d-flex gap-1 flex-wrap">
                                    <h5 class="mb-0">{{translate('request_time').':'.' '}}</h5>
                                    <div class="fs-12">{{$withdrawRequest->created_at}}</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="d-flex gap-1">
                                    <div class="text-dark">{{translate('note').':'.' '}}</div>
                                    <div>{{$withdrawRequest->transaction_note ?: '-'}}</div>
                                </div>
                            </div>
                        </div>
                        <div class="mt-3">
                            @if ($withdrawRequest->approved == 0)
                                <button type="button" class="btn btn-success" data-bs-toggle="modal"
                                        data-bs-target="#processModal">{{translate('proceed')}}
                                    <i class="fi fi-rr-angle-double-small-right"></i>
                                </button>
                            @else
                                <label class="badge badge-{{$withdrawRequest->approved == 1 ? 'success' : 'danger'}} text-bg-{{$withdrawRequest->approved == 1 ? 'success' : 'danger'}}">
                                    {{translate($withdrawRequest->approved == 1 ? 'approved' : 'denied')}}
                                </label>
                            @endif
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4 mb-3">
                <div class="card h-100">
                    <div class="card-body text-start">
                        <div class="text-capitalize d-flex align-items-center justify-content-between gap-2 border-bottom pb-3 mb-4">
                            <h3 class="h3 mb-0">{{translate('affiliate_info')}}</h3>
                            <i class="fi fi-sr-user fs-5"></i>
                        </div>
                        @if($withdrawRequest->affiliate)
                            <div class="d-flex gap-1 align-items-center flex-wrap">
                                <h5 class="mb-0">{{translate('name').' '.':'}}</h5>
                                <h5 class="mb-0">
                                    <a href="{{ route('admin.affiliate.view', $withdrawRequest->affiliate->id) }}">
                                        {{$withdrawRequest->affiliate->f_name.' '.$withdrawRequest->affiliate->l_name}}
                                    </a>
                                </h5>
                            </div>
                            <div class="d-flex gap-1 align-items-center flex-wrap">
                                <h5 class="mb-0">{{translate('email').' '.':'}}</h5>
                                <h5 class="mb-0">{{$withdrawRequest->affiliate->email}}</h5>
                            </div>
                            <div class="d-flex gap-1 align-items-center flex-wrap">
                                <h5 class="mb-0">{{translate('phone').' '.':'}}</h5>
                                <h5 class="mb-0">{{$withdrawRequest->affiliate->phone ?: '-'}}</h5>
                            </div>
                        @else
                            <span class="text-muted">{{translate('not_found')}}</span>
                        @endif
                    </div>
                </div>
            </div>

            <div class="modal fade" id="processModal" tabindex="-1" role="dialog" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3 class="modal-title">{{translate('withdraw_request_process')}}</h3>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <form action="{{route('admin.affiliate.withdraw-status-update',[$withdrawRequest->id])}}" method="POST">
                            @csrf
                            <div class="modal-body">
                                <div class="form-group">
                                    <label class="col-form-label">{{translate('request')}}:</label>
                                    <select name="approved" class="custom-select form-select">
                                        <option value="1">{{translate('approve')}}</option>
                                        <option value="2">{{translate('deny')}}</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label class="col-form-label">{{translate('note_about_transaction_or_request')}}:</label>
                                    <textarea class="form-control" name="note"></textarea>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">{{translate('close')}}</button>
                                <button type="submit" class="btn btn-primary">{{translate('submit')}}</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
