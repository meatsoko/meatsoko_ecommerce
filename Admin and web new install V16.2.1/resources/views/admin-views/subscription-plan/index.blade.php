@extends('layouts.admin.app')

@section('title', translate('Subscription_Plans'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Subscription_Plans')}}
            </h2>
            <div class="d-flex gap-2">
                <a href="{{ route('admin.subscription-plan.add') }}" class="btn btn-primary">
                    {{translate('Add_Plan')}}
                </a>
                <a href="{{ route('admin.subscription.subscribers') }}" class="btn btn-outline-primary">
                    {{translate('subscribers')}}
                </a>
                <a href="{{ route('admin.subscription-plan.settings') }}" class="btn btn-outline-primary">
                    {{translate('Subscription_Settings')}}
                </a>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body d-flex flex-column gap-20">
                        <div class="d-flex justify-content-between align-items-center gap-20 flex-wrap">
                            <h3 class="mb-0">
                                {{ translate('all_plans')}}
                                <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $plans->total() }}</span>
                            </h3>
                            <form action="{{ url()->current() }}" method="get" class="flex-grow-1 max-w-300 min-w-100-mobile">
                                <div class="input-group">
                                    <input type="search" name="searchValue" class="form-control"
                                           placeholder="{{translate('search_by_title')}}"
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
                                        <th>{{translate('title')}}</th>
                                        <th>{{translate('cadence')}}</th>
                                        <th>{{translate('price')}}</th>
                                        <th>{{translate('box_products')}}</th>
                                        <th>{{translate('subscribers')}}</th>
                                        <th>{{translate('status')}}</th>
                                        <th class="text-center">{{translate('action')}}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                @foreach($plans as $plan)
                                    <tr>
                                        <td>{{ $plan->title }}</td>
                                        <td class="text-capitalize">{{ translate($plan->cadence) }}</td>
                                        <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $plan->price)) }}</td>
                                        <td>
                                            <a href="{{ route('admin.subscription-plan.products', $plan->id) }}">
                                                {{ $plan->products->count() }} {{ translate('products') }}
                                            </a>
                                        </td>
                                        <td>{{ $plan->subscriptions->count() }}</td>
                                        <td>
                                            @if($plan->status == 'active')
                                                <span class="badge bg-soft-success text-success">{{ translate('active') }}</span>
                                            @else
                                                <span class="badge bg-soft-danger text-danger">{{ translate('inactive') }}</span>
                                            @endif
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                <a href="{{ route('admin.subscription-plan.edit', $plan->id) }}" class="btn btn-outline-primary btn-sm">{{ translate('edit') }}</a>
                                                <form action="{{ route('admin.subscription-plan.status-update', $plan->id) }}" method="post">
                                                    @csrf
                                                    <input type="hidden" name="status" value="{{ $plan->status == 'active' ? 'inactive' : 'active' }}">
                                                    <button type="submit" class="btn btn-outline-{{ $plan->status == 'active' ? 'danger' : 'success' }} btn-sm">
                                                        {{ translate($plan->status == 'active' ? 'deactivate' : 'activate') }}
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                @endforeach
                                </tbody>
                            </table>
                            <table class="mt-4">
                                <tfoot>
                                {!! $plans->links() !!}
                                </tfoot>
                            </table>
                        </div>
                        @if(count($plans) <= 0)
                            @include('layouts.admin.partials._empty-state',['text'=>'no_data_found'],['image'=>'default'])
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
