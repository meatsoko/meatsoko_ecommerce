@extends('layouts.admin.app')

@section('title', $pageTitle)

@section('content')
    <div class="content container-fluid">

        <div class="mb-4 d-flex align-items-center justify-content-between flex-wrap gap-2">
            <h1 class="mb-1 text-capitalize d-flex gap-2">
                <img src="{{dynamicAsset(path: 'public/assets/back-end/img/bulk-import.png')}}" alt="">
                {{ $pageTitle }}
            </h1>
            <a href="{{ $backRoute }}" class="btn btn-outline-primary">
                <i class="fi fi-rr-list"></i>
                <span class="fs-12">{{ translate('back_to_list') }}</span>
            </a>
        </div>

        @if(!empty($importErrors))
            <div class="card mb-20 border-danger">
                <div class="card-body">
                    <h3 class="fs-16 text-danger mb-15px">{{ translate('rows_skipped_during_last_import') }} ({{ count($importErrors) }})</h3>
                    <ul class="mb-0 ps-3">
                        @foreach($importErrors as $error)
                            <li class="text-dark fs-13">{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            </div>
        @endif

        <div class="card mb-20">
            <div class="card-body">
                <div class="row g-4 mb-20">
                    <div class="col-md-6 col-lg-4">
                        <div class="border rounded-3 p-4 bg-white h-100">
                            <div class="p-xl-1">
                                <div class="d-flex align-items-center justify-content-between gap-2 mb-20">
                                    <div class="cont">
                                        <h3 class="fs-20 font-weight-normal fw-normal mb-1 lh-base d-block text-dark">{{ translate('Step_1') }} : </h3>
                                        <p class="fs-12 m-0 max-w-150px">{{ translate('Download_Excel_File') }}</p>
                                    </div>
                                    <img width="60" src="{{dynamicAsset(path: 'public/assets/back-end/img/xlsx-down.png')}}" alt="">
                                </div>
                                <div>
                                    <div class="fs-12 text-dark fw-semibold font-weight-semibold mb-3">
                                        {{ translate('Instruction') }}
                                    </div>
                                    <ul class="d-flex flex-column gap-10 ps-3 list-group">
                                        <li class="text-dark fs-12">
                                            {{ translate('Download the format file to get the required column structure.') }}
                                        </li>
                                        <li class="text-dark fs-12">
                                            {{ translate('Check the example row for accurate data input guidance.') }}
                                        </li>
                                        <li class="text-dark fs-12">
                                            {{ translate('Please upload the xlsx or excel file') }}
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-4">
                        <div class="border rounded-3 p-4 bg-white h-100">
                            <div class="p-xl-1">
                                <div class="d-flex align-items-center justify-content-between gap-2 mb-20">
                                    <div class="cont">
                                        <h3 class="fs-20 font-weight-normal fw-normal mb-1 lh-base d-block text-dark">{{ translate('Step_2') }} : </h3>
                                        <p class="fs-12 m-0 max-w-150px">{{ translate('Match_Spread_sheet_data_according_to_instruction') }}</p>
                                    </div>
                                    <img width="60" src="{{dynamicAsset(path: 'public/assets/back-end/img/proper-sheet.png')}}" alt="">
                                </div>
                                <div>
                                    <div class="fs-12 text-dark fw-semibold font-weight-semibold mb-3">
                                        {{ translate('Column_Guide') }}
                                    </div>
                                    <ul class="d-flex flex-column gap-10 ps-3 list-group">
                                        <li class="text-dark fs-12">
                                            <b>name</b> — {{ translate('required_the_brand_name_must_be_unique') }}
                                        </li>
                                        <li class="text-dark fs-12">
                                            <b>image_alt_text</b> — {{ translate('optional_alt_text_shown_for_the_brand_image') }}
                                        </li>
                                        <li class="text-dark fs-12">
                                            <b>status</b> — {{ translate('optional_1_for_active_0_for_inactive_defaults_to_active') }}
                                        </li>
                                        <li class="text-dark fs-12">
                                            {{ translate('a_default_placeholder_image_is_used_you_can_edit_each_brand_afterward_to_upload_its_real_logo') }}
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-4">
                        <div class="border rounded-3 p-4 bg-white h-100">
                            <div class="p-xl-1">
                                <div class="d-flex align-items-center justify-content-between gap-2 mb-20">
                                    <div class="cont">
                                        <h3 class="fs-20 font-weight-normal fw-normal mb-1 lh-base d-block text-dark">{{ translate('Step_3') }} : </h3>
                                        <p class="fs-12 m-0 max-w-150px">{{ translate('Validate_data_and_complete_import') }}</p>
                                    </div>
                                    <img width="60" src="{{dynamicAsset(path: 'public/assets/back-end/img/xlsx-up.png')}}" alt="">
                                </div>
                                <div>
                                    <div class="fs-12 text-dark fw-semibold font-weight-semibold mb-3">
                                        {{ translate('Instruction') }}
                                    </div>
                                    <ul class="d-flex flex-column gap-10 ps-3 list-group">
                                        <li class="text-dark fs-12">
                                            {{ translate('Upload your completed Excel or xlsx file using the upload tool.') }}
                                        </li>
                                        <li class="text-dark fs-12">
                                            {{ translate('rows_with_invalid_or_duplicate_data_are_skipped_and_reported_after_import') }}
                                        </li>
                                        <li class="text-dark fs-12">
                                            {{ translate('valid_rows_are_added_immediately_you_can_edit_each_entry_afterward_to_add_an_image') }}
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-center">
                    <p class="mb-15px fs-16 text-dark">{{ translate('Download_Spreadsheet_Template') }}</p>
                    <div class="d-flex align-items-center gap-3 justify-content-center flex-wrap">
                        <a href="{{ $templateAction }}"
                           class="btn btn-primary px-4 fs-14 fw-medium min-h-40">{{translate('Download_Template')}}</a>
                    </div>
                </div>
            </div>
        </div>
        <form class="brand-import-form form-advance-validation form-advance-inputs-validation form-advance-file-validation non-ajax-form-validate" action="{{ $formAction }}" method="POST"
                enctype="multipart/form-data" novalidate="novalidate">
            @csrf
            <div class="card rest-part">
                <div class="card-body">
                    <div class="text-center mb-20">
                        <h3 class="mb-0 fs16">{{translate("Import items file")}} ?</h3>
                    </div>
                    <div class="form-group mb-20">
                        <div class="row justify-content-center">
                            <div class="max-w-500 uplad-xls-file">
                                <div class="uploadDnD position-relative pt-3">
                                    <label for="inputFile" class="text-center d-block" style="cursor:pointer;">
                                        <img width="54"
                                             src="{{dynamicAsset(path: 'public/assets/back-end/img/xlsx-up.png')}}"
                                             alt=""
                                             class="view-img position- object-contain">
                                    </label>
                                    <div class="form-group inputDnD input_image input_image_edit"
                                         data-title="{{translate('drag_&_drop_file_or_browse_file')}}">
                                        <div class="text-center">
                                            <input type="file"
                                                   name="brands_file"
                                                   accept=".xlsx, .xls"
                                                   class="form-control-file font-weight-bold action-upload-section-dot-area"
                                                   data-max-size="{{ getFileUploadMaxSize(type: 'file') }}"
                                                   data-required-msg="{{ translate('file_field_is_required') }}"
                                                   id="inputFile"
                                                   required>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-wrap gap-10 align-items-center justify-content-end mt-4">
                        <button type="reset" class="btn btn-secondary px-4 action-onclick-reload-page">{{translate('reset')}}</button>
                        <button type="submit" class="btn btn-primary px-4">{{translate('submit')}}</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
@endsection
