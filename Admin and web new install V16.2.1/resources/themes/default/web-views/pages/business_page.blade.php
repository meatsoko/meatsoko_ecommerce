@extends('layouts.front-end.app')

@section('title', $businessPage?->title)

@section('content')
    <div class="container for-container">
        <nav class="ms-breadcrumb" aria-label="Breadcrumb">
            <a href="{{ route('home') }}">{{ translate('home') }}</a>
            <span class="ms-sep">/</span>
            <span class="ms-current">{{ $businessPage?->title }}</span>
        </nav>
        <div class="business-pages-banner-section mt-1 {{ empty($businessPage?->description) ? 'mb-4' : '' }}"
             data-bg-img="{{ getStorageImages(path: $businessPage?->banner_full_url, type: 'business-page') }}">
            <div class="container">
                <h1 class="text-center text-capitalize font-semi-bold fs-24">{{ $businessPage?->title }}</h1>
            </div>
        </div>

        @if(!empty($businessPage?->description))
            <div class="card my-4">
                <div class="card-body">
                    <div class="for-padding">
                        {!! $businessPage?->description !!}
                    </div>
                </div>
            </div>
        @endif
    </div>
@endsection
