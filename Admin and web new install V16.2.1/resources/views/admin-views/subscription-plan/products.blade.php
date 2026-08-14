@extends('layouts.admin.app')

@section('title', translate('Box_Products'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Box_Products')}} — {{ $plan->title }}
            </h2>
            <a href="{{ route('admin.subscription-plan.list') }}" class="btn btn-outline-secondary">{{translate('back_to_list')}}</a>
        </div>

        <div class="card mb-3">
            <div class="card-body">
                <h3 class="mb-3">
                    {{ translate('box_contents') }}
                    <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $plan->products->count() }}</span>
                </h3>
                @if($plan->products->count() > 0)
                    <form action="{{ route('admin.subscription-plan.products.update-quantities', $plan->id) }}" method="post">
                        @csrf
                        <div class="table-responsive">
                            <table class="table table-hover table-borderless align-middle">
                                <thead class="text-capitalize">
                                <tr>
                                    <th>{{translate('product')}}</th>
                                    <th>{{translate('unit_price')}}</th>
                                    <th class="min-w-120">{{translate('quantity_in_box')}}</th>
                                    <th class="text-center">{{translate('action')}}</th>
                                </tr>
                                </thead>
                                <tbody>
                                @foreach($plan->products as $planProduct)
                                    <tr>
                                        <td>{{ $planProduct->product->name ?? translate('product_not_found') }}</td>
                                        <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $planProduct->product->unit_price ?? 0)) }}</td>
                                        <td>
                                            <input type="number" min="1" name="quantity[{{ $planProduct->product_id }}]"
                                                   class="form-control" style="max-width: 100px;" value="{{ $planProduct->quantity }}">
                                        </td>
                                        <td class="text-center">
                                            <button type="submit" form="remove-product-{{ $planProduct->product_id }}"
                                                    class="btn btn-outline-danger btn-sm">{{ translate('remove') }}</button>
                                        </td>
                                    </tr>
                                @endforeach
                                </tbody>
                            </table>
                        </div>
                        <button type="submit" class="btn btn-primary">{{ translate('update_quantities') }}</button>
                    </form>
                    @foreach($plan->products as $planProduct)
                        <form id="remove-product-{{ $planProduct->product_id }}"
                              action="{{ route('admin.subscription-plan.products.remove', [$plan->id, $planProduct->product_id]) }}" method="post">
                            @csrf
                        </form>
                    @endforeach
                @else
                    @include('layouts.admin.partials._empty-state',['text'=>'no_products_in_this_box_yet'],['image'=>'default'])
                @endif
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <h3 class="mb-3">{{ translate('add_products_to_box') }}</h3>
                <form action="{{ route('admin.subscription-plan.products.add', $plan->id) }}" method="post">
                    @csrf
                    <div class="mb-3 max-w-300">
                        <div class="input-group">
                            <input type="search" name="searchValue" class="form-control" placeholder="{{translate('search_by_product_name')}}" value="{{ request('searchValue') }}" form="product-search-form">
                            <button type="submit" form="product-search-form" class="btn btn-outline-secondary"><i class="fi fi-rr-search"></i></button>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover table-borderless align-middle">
                            <thead class="text-capitalize">
                            <tr>
                                <th></th>
                                <th>{{translate('product')}}</th>
                                <th>{{translate('unit_price')}}</th>
                                <th class="min-w-120">{{translate('quantity_in_box')}}</th>
                            </tr>
                            </thead>
                            <tbody>
                            @forelse($products as $product)
                                <tr>
                                    <td><input type="checkbox" name="product_id[]" value="{{ $product->id }}"></td>
                                    <td>{{ $product->name }}</td>
                                    <td>{{ setCurrencySymbol(amount: usdToDefaultCurrency(amount: $product->unit_price)) }}</td>
                                    <td>
                                        <input type="number" min="1" name="quantity[{{ $product->id }}]"
                                               class="form-control" style="max-width: 100px;" value="1">
                                    </td>
                                </tr>
                            @empty
                                <tr><td colspan="4" class="text-center text-muted py-4">{{ translate('no_more_in_house_products_available') }}</td></tr>
                            @endforelse
                            </tbody>
                        </table>
                        <table class="mt-4">
                            <tfoot>
                            {!! $products->links() !!}
                            </tfoot>
                        </table>
                    </div>

                    <button type="submit" class="btn btn-primary">{{ translate('add_selected_products') }}</button>
                </form>
            </div>
        </div>
    </div>
    <form id="product-search-form" action="{{ route('admin.subscription-plan.products', $plan->id) }}" method="get"></form>
@endsection
