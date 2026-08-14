@extends('layouts.admin.app')

@section('title', translate(isset($plan) ? 'Edit_Plan' : 'Add_Plan'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate(isset($plan) ? 'Edit_Plan' : 'Add_Plan')}}
            </h2>
        </div>

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body">
                        <form action="{{ isset($plan) ? route('admin.subscription-plan.update', $plan->id) : route('admin.subscription-plan.store') }}"
                              method="post" enctype="multipart/form-data">
                            @csrf
                            <div class="row">
                                <div class="col-md-12 form-group mb-3">
                                    <label class="form-label">{{ translate('title') }}</label>
                                    <input type="text" name="title" class="form-control" value="{{ $plan->title ?? old('title') }}" required>
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('cadence') }}</label>
                                    <select name="cadence" class="form-select" required>
                                        <option value="weekly" {{ (($plan->cadence ?? '') == 'weekly') ? 'selected' : '' }}>{{ translate('weekly') }}</option>
                                        <option value="monthly" {{ (($plan->cadence ?? '') == 'monthly') ? 'selected' : '' }}>{{ translate('monthly') }}</option>
                                    </select>
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('price') }}</label>
                                    <input type="number" step="0.01" min="0.01" name="price" class="form-control" value="{{ $plan->price ?? old('price') }}" required>
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('shipping_cost') }}</label>
                                    <input type="number" step="0.01" min="0" name="shipping_cost" class="form-control" value="{{ $plan->shipping_cost ?? 0 }}">
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('image') }}</label>
                                    <input type="file" name="image" class="form-control" accept="image/*">
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary">{{ translate(isset($plan) ? 'update' : 'save_&_next') }}</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
