<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Affiliate') - {{ getWebConfig(name: 'company_name') ?? config('app.name') }}</title>
    <link rel="stylesheet" href="{{ dynamicAsset(path: 'public/assets/back-end/libs/bootstrap-5/bootstrap.min.css') }}">
    <style>
        body { background:#f5f5f5; }
        .affiliate-navbar { background:#fff; border-bottom:1px solid #e5e5e5; }
        .affiliate-card { background:#fff; border:1px solid #e5e5e5; border-radius:8px; }
        .stat-box { background:#fff; border:1px solid #e5e5e5; border-radius:8px; padding:1.25rem; }
        .stat-box .value { font-size:1.6rem; font-weight:700; }
        .stat-box .label { font-size:.8rem; color:#888; text-transform:uppercase; letter-spacing:.03em; }
        code.affiliate-code { font-size:1.1rem; padding:.35rem .6rem; background:#eef1f5; border-radius:6px; }
    </style>
    @stack('script')
</head>
<body>
@if(auth('affiliate')->check())
    <nav class="navbar navbar-expand affiliate-navbar px-3 mb-4">
        <span class="navbar-brand fw-bold">{{ translate('Affiliate_Program') }}</span>
        <div class="ms-auto d-flex align-items-center gap-3">
            <span class="text-muted small">{{ auth('affiliate')->user()->f_name }}</span>
            <a href="{{ route('affiliate.dashboard') }}" class="btn btn-sm btn-outline-secondary">{{ translate('dashboard') }}</a>
            <a href="{{ route('affiliate.auth.logout') }}" class="btn btn-sm btn-outline-danger">{{ translate('logout') }}</a>
        </div>
    </nav>
@endif
<div class="container py-3">
    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif
    @if(session('error'))
        <div class="alert alert-danger">{{ session('error') }}</div>
    @endif
    @if($errors->any())
        <div class="alert alert-danger">
            <ul class="mb-0">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif
    @yield('content')
</div>
<script src="{{ dynamicAsset(path: 'public/assets/back-end/libs/bootstrap-5/bootstrap.bundle.min.js') }}"></script>
</body>
</html>
