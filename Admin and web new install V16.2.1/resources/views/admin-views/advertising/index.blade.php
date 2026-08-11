@extends('layouts.admin.app')

@section('title', translate('Sponsored_Placements'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Sponsored_Placements')}}
            </h2>
            <a href="{{ route('admin.advertising.settings') }}" class="btn btn-outline-primary">
                {{translate('Advertising_Settings')}}
            </a>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-body d-flex flex-column gap-20">
                        <h3 class="mb-0">
                            {{ translate('all_placements')}}
                            <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">{{ $placements->total() }}</span>
                        </h3>

                        <div class="table-responsive">
                            <table class="table table-hover table-borderless align-middle">
                                <thead class="text-capitalize">
                                    <tr>
                                        <th>{{translate('vendor')}}</th>
                                        <th>{{translate('product')}}</th>
                                        <th>{{translate('days')}}</th>
                                        <th>{{translate('amount_paid')}}</th>
                                        <th>{{translate('starts')}}</th>
                                        <th>{{translate('ends')}}</th>
                                        <th>{{translate('status')}}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                @foreach($placements as $placement)
                                    <tr>
                                        <td>{{ $placement->seller?->f_name }} {{ $placement->seller?->l_name }}</td>
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
                                @endforeach
                                </tbody>
                            </table>
                            <table class="mt-4">
                                <tfoot>
                                {!! $placements->links() !!}
                                </tfoot>
                            </table>
                        </div>
                        @if(count($placements) <= 0)
                            @include('layouts.admin.partials._empty-state',['text'=>'no_data_found'],['image'=>'default'])
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
