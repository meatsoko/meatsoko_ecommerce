@if(count($bannerTypeMainBanner) > 0)
    @php($showTodaysDealBox = !empty($flashDeal['flashDeal']) && !empty($flashDeal['flashDealProducts']) && count($flashDeal['flashDealProducts']) > 0)
<section class="bg-transparent pt-3">
    <div class="container position-relative">
        <div class="row no-gutters position-relative rtl {{ $showTodaysDealBox ? 'has-todays-deal' : '' }}">
            @if ($categories->count() > 0 )
                <div class="col-xl-3 position-static d-none d-xl-block __top-slider-cate">
                    <div class="category-menu-wrap position-static">
                        <ul class="category-menu mt-0">
                            @foreach ($categories as $key=>$category)
                                <li>
                                    <a href="{{ route('category-products', ['slug' => $category['slug']]) }}">
                                        <span class="d-flex gap-10px justify-content-start align-items-center">
                                            <img class="aspect-1 rounded-circle" width="20" src="{{ getStorageImages(path: $category?->icon_full_url, type: 'category') }}" alt="{{ $category['name'] }}">
                                            <span class="line--limit-2">{{ $category->name }}</span>
                                        </span>
                                    </a>
                                    @if ($category->childes->count() > 0)
                                        <div class="mega_menu z-2">
                                            @foreach ($category->childes as $sub_category)
                                                <div class="mega_menu_inner">
                                                    <h6><a href="{{ route('category-products', ['slug' => $sub_category['slug']]) }}">{{$sub_category->name}}</a></h6>
                                                    @if ($sub_category->childes->count() >0)
                                                        @foreach ($sub_category->childes as $sub_sub_category)
                                                            <div>
                                                                <a href="{{ route('category-products', ['slug' => $sub_sub_category['slug']]) }}">
                                                                    {{ $sub_sub_category->name }}
                                                                </a>
                                                            </div>
                                                        @endforeach
                                                    @endif
                                                </div>
                                            @endforeach
                                        </div>
                                    @endif
                                </li>
                            @endforeach
                            <li class="text-center">
                                <a href="{{route('categories')}}" class="text-primary font-weight-bold justify-content-center text-capitalize view-all-btn-text">
                                    {{translate('view_all')}}
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            @endif

            <div class="col-12 {{ $showTodaysDealBox ? 'col-xl-7' : 'col-xl-9' }} __top-slider-images">
                <div class="{{Session::get('direction') === "rtl" ? 'pr-xl-2' : 'pl-xl-2'}}">
                    <div class="owl-theme owl-carousel hero-slider" data-loop="{{ count($bannerTypeMainBanner) > 1 ? 1 : 0 }}">
                        @foreach($bannerTypeMainBanner as $key=>$banner)
                            <a href="{{$banner['url']}}" class="d-block" target="_blank">
                                <img class="w-100 __slide-img __slide-img-170" alt="{{ translate('Banner') }}"
                                    src="{{ getStorageImages(path: $banner->photo_full_url, type: 'banner') }}">
                            </a>
                        @endforeach
                    </div>
                </div>
            </div>

            @if ($showTodaysDealBox)
                <div class="col-xl-2 position-static d-none d-xl-block __top-slider-deal">
                    <div class="{{Session::get('direction') === "rtl" ? 'pr-xl-2' : 'pl-xl-2'}} h-100">
                        <div class="bg--light rounded h-100 p-3 d-flex flex-column __today-deal-box">
                            <div class="d-flex align-items-center justify-content-between gap-2 mb-3">
                                <h3 class="fs-14 font-bold text-uppercase mb-0 text-dark line--limit-1">
                                    {{ translate('todays_deal') }}
                                </h3>
                                <span class="badge bg-danger text-white text-uppercase fs-10">{{ translate('hot') }}</span>
                            </div>
                            <div class="d-flex flex-column gap-3 flex-grow-1">
                                @foreach($flashDeal['flashDealProducts']->take(3) as $product)
                                    <a href="{{ route('product', $product->slug) }}" class="d-flex align-items-center gap-2 __today-deal-item text-decoration-none">
                                        <img loading="lazy" width="50" height="50" alt="{{ $product['name'] }}"
                                             class="rounded border object-fit-cover flex-shrink-0"
                                             src="{{ getStorageImages(path: $product->thumbnail_full_url, type: 'product') }}">
                                        <div class="d-flex flex-column lh-1">
                                            @if(getProductPriceByType(product: $product, type: 'discount', result: 'value') > 0)
                                                <del class="fs-11 __color-9B9B9B">{{ webCurrencyConverter(amount: $product->unit_price) }}</del>
                                            @endif
                                            <span class="fs-13 font-bold text-dark">
                                                {{ getProductPriceByType(product: $product, type: 'discounted_unit_price', result: 'string') }}
                                            </span>
                                        </div>
                                    </a>
                                @endforeach
                            </div>
                            <a href="{{ route('flash-deals', ['id' => $web_config['flash_deals'] ? $web_config['flash_deals']['id'] : 0]) }}"
                               class="text-capitalize view-all-btn-text mt-3 text-center">
                                <span class="view-btn-text">{{ translate('View_All') }}</span>
                                <i class="czi-arrow-{{ session('direction') === "rtl" ? 'left' : 'right' }}"></i>
                            </a>
                        </div>
                    </div>
                </div>
            @endif
        </div>
    </div>
</section>
@endif
