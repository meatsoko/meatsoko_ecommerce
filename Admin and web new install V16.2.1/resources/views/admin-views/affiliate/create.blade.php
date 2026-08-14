@extends('layouts.admin.app')

@section('title', translate('Add_Affiliate'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex align-items-center gap-2">
                {{translate('Add_Affiliate')}}
            </h2>
        </div>

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body">
                        <form action="{{ route('admin.affiliate.store') }}" method="post">
                            @csrf
                            <div class="row">
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('first_name') }}</label>
                                    <input type="text" name="f_name" class="form-control" value="{{ old('f_name') }}" required>
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('last_name') }}</label>
                                    <input type="text" name="l_name" class="form-control" value="{{ old('l_name') }}">
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('email') }}</label>
                                    <input type="email" name="email" class="form-control" value="{{ old('email') }}" required>
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('phone') }}</label>
                                    <input type="text" name="phone" class="form-control" value="{{ old('phone') }}">
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('password') }}</label>
                                    <input type="password" name="password" class="form-control" required>
                                </div>
                                <div class="col-md-6 form-group mb-3">
                                    <label class="form-label">{{ translate('confirm_password') }}</label>
                                    <input type="password" name="confirm_password" class="form-control" required>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary">{{ translate('save') }}</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
