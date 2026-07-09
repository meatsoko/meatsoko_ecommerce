import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/buttons_tab_bar.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/category_content_screen_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/todays_deal_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/controllers/auction_home_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/clearance_sale/widgets/clearance_sale_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/home_category_content.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/auction_product_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/banner_slider_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/featured_products_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/flash_deal_section.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/new_user_exclusive_section.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/top_stores_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/product_type_extension.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeExploreScreen extends StatefulWidget {
  final VoidCallback? onAuctionSeeAll;
  final ValueListenable<int>? resetToExploreListenable;
  const HomeExploreScreen({super.key, this.onAuctionSeeAll, this.resetToExploreListenable});

  @override
  State<HomeExploreScreen> createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, double> _tabScrollOffsets = {};
  bool _switchingToCategory = false;

  static const double _refreshEdgeOffset = 113;

  TabController? _tabController;
  TabController? _productTabController;
  late final bool _isAuctionEnabled;
  late final bool _singleVendor;

  final GlobalKey _buttonsTabBarKey = GlobalKey();
  final GlobalKey _nestedKey = GlobalKey();
  bool _buttonsTabPinned = false;
  static const double _categoryTabBarHeight = 48;
  static const double _searchBarHeight = 75;

  late final AnimationController _tabBarRevealAnim;

  final List<ProductType> _productTypes = const [
    ProductType.newArrival,
    ProductType.topProduct,
    ProductType.bestSelling,
    ProductType.discountedProduct,
  ];

  @override
  void initState() {
    super.initState();
    final splash = Provider.of<SplashController>(Get.context!, listen: false);
    _isAuctionEnabled = splash.configModel?.isAuctionFeatureEnabled ?? false;
    _singleVendor = splash.configModel?.businessMode == 'single';
    _tabBarRevealAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: 1.0,
    )..addListener(() => setState(() {}));
    _initTabs();
    _scrollController.addListener(_onScroll);
    widget.resetToExploreListenable?.addListener(_resetToExplore);
  }

  void _resetToExplore() {
    if (_tabController != null && _tabController!.index != 0) {
      _tabController!.animateTo(0);
    }
  }

  void _onScroll() {
    final bool onExploreTab = _tabController == null || _tabController!.index == 0;
    if (!onExploreTab) return;

    final ctx = _buttonsTabBarKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox?;
    final nestedBox = _nestedKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || nestedBox == null) return;

    final double topY = box.localToGlobal(Offset.zero).dy;
    final double originY = nestedBox.localToGlobal(Offset.zero).dy;
    final double rel = topY - originY;

    const double enterLine = _categoryTabBarHeight + _searchBarHeight;
    const double exitLine = enterLine + 0;

    final bool next = _buttonsTabPinned ? (rel < exitLine) : (rel <= enterLine);
    if (next != _buttonsTabPinned) {
      _buttonsTabPinned = next;
      if (next) {
        _tabBarRevealAnim.animateTo(0.0, curve: Curves.easeOut);
      } else {
        _tabBarRevealAnim.animateTo(1.0, curve: Curves.easeIn);
      }
    }
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: () => RouterHelper.getSearchRoute(action: RouteAction.push),
        child: SearchHomePageWidget(isCompact: true),
      ),
    );
  }

  int _scrollKeyForTab(int tabIndex) {
    if (tabIndex == 0) return -1;
    final categories = Provider.of<CategoryController>(context, listen: false).categoryList;
    return categories[tabIndex - 1].id ?? -1;
  }

  Future<void> _refreshData() async {
    final productController   = Provider.of<ProductController>(context, listen: false);
    final categoryController  = Provider.of<CategoryController>(context, listen: false);
    final profileController   = Provider.of<ProfileController>(context, listen: false);
    final authController      = Provider.of<AuthController>(context, listen: false);
    final flashDealController = Provider.of<FlashDealController>(context, listen: false);
    final bannerController    = Provider.of<BannerController>(context, listen: false);
    final shopController      = Provider.of<ShopController>(context, listen: false);
    final auctionController   = _isAuctionEnabled ? Provider.of<AuctionHomeController>(context, listen: false) : null;
    final isLoggedIn = authController.isLoggedIn();

    _tabScrollOffsets.clear();
    _buttonsTabPinned = false;
    _tabBarRevealAnim.value = 1.0;
    productController.clearCategoryProductCache();
    await profileController.getUserInfo(context, isLoggedIn: isLoggedIn);
    await categoryController.getCategoryList(true);
    await flashDealController.getFlashDealList(false, false);
    await bannerController.getBannerList();
    await productController.getFeaturedProductModel(1);
    await productController.getRecommendedProduct();
    await productController.getJustForYouProduct(1);
    await productController.getClearanceAllProductList(1);
    await shopController.getTopSellerList(offset: 1);
    if (auctionController != null) {
      await auctionController.getAuctionHomeSection(AuctionEnum.all);
    }
    _initTabs();
  }

  void _initTabs() {
    final categories = Provider.of<CategoryController>(context, listen: false).categoryList;
    final tabCount = 1 + categories.length;

    if (_tabController == null || _tabController!.length != tabCount) {
      _tabController?.dispose();
      _tabController = TabController(length: tabCount, vsync: this);

      bool wasOnExplore = _tabController!.index == 0;
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) {
          final previousKey = _scrollKeyForTab(_tabController!.previousIndex);
          final incomingKey = _scrollKeyForTab(_tabController!.index);

          _tabScrollOffsets[previousKey] = _scrollController.offset;
          // Reset so the category TabBar shows its real 48px bottom before the
          // incoming category tab's overlap injector reads the absorber.
          _buttonsTabPinned = false;
          _tabBarRevealAnim.value = 1.0;
          _scrollController.jumpTo(_tabScrollOffsets[incomingKey] ?? 0.0);
        }
        final bool nowOnExplore = _tabController!.index == 0;
        final bool enteringCategory = _tabController!.indexIsChanging &&
            _tabController!.previousIndex == 0 &&
            _tabController!.index != 0;
        if (nowOnExplore != wasOnExplore || enteringCategory != _switchingToCategory) {
          wasOnExplore = nowOnExplore;
          _switchingToCategory = enteringCategory;
          setState(() {});
        }
      });
    }

    _productTabController ??= TabController(length: _productTypes.length, vsync: this);
    setState(() {});
  }

  @override
  void dispose() {
    widget.resetToExploreListenable?.removeListener(_resetToExplore);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabBarRevealAnim.dispose();
    _tabController?.dispose();
    _productTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        if (_tabController != null && _tabController!.index != 0) {
          _tabController!.animateTo(0);
          return true;
        }
        return false;
      },
      child: Consumer<CategoryController>(
        builder: (context, categoryController, _) {
          final categories = categoryController.categoryList;
          final expectedLength = 1 + categories.length;

          if (_tabController == null || _tabController!.length != expectedLength) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _initTabs());
          }

          final bool onExploreTab = _tabController == null || _tabController!.index == 0;
          final double revealT = onExploreTab ? _tabBarRevealAnim.value : 1.0;

          return Container(
            color: Color.lerp(Theme.of(context).cardColor, Theme.of(context).primaryColor, revealT),
            child: SafeArea(
              bottom: false,
              child: Scaffold(
                body: RefreshIndicator(
                  edgeOffset: _refreshEdgeOffset,
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  notificationPredicate: (notification) => notification is OverscrollNotification || notification.depth != 2,
                  onRefresh: () async => _refreshData(),
                  child: (_tabController == null ||
                      _productTabController == null)
                      ? const Center(child: CircularProgressIndicator())
                      : NestedScrollView(
                    key: _nestedKey,
                    controller: _scrollController,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          floating: false,
                          elevation: 0,
                          centerTitle: false,
                          automaticallyImplyLeading: false,
                          backgroundColor: Theme.of(context).primaryColor,
                          expandedHeight: 65,
                          flexibleSpace: _CustomizableSpaceBarWidget(
                            builder: (ctx, scrollingRate, child) => Opacity(
                              opacity: (1 - scrollingRate).clamp(0.0, 1.0),
                              child: child,
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeSmall),
                                child: Consumer<ProfileController>(
                                  builder: (context, profileController, _) {
                                    final bool isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
                                    final String firstLine = isLoggedIn
                                        ? getTranslated('hello_welcome', context)!
                                        : getTranslated('hello', context)!;
                                    final String secondLine = isLoggedIn
                                        ? (profileController.userInfoModel?.fName ?? '')
                                        : getTranslated('welcome', context)!;
                                    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                firstLine,
                                                style: titilliumRegular.copyWith(
                                                  color: Colors.white,
                                                  fontSize: Dimensions.fontSizeDefault,
                                                ),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                                              Text(secondLine,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: titilliumBold.copyWith(
                                                  color: Colors.white,
                                                  fontSize: Dimensions.fontSizeLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => RouterHelper.getMoreScreenRoute(action: RouteAction.push),
                                          child: ClipOval(
                                            child: CustomImageWidget(
                                                image: profileController.userInfoModel?.imageFullUrl?.path ?? '',
                                                width: 40, height: 40, placeholder: Images.guestProfile),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        SliverOverlapAbsorber(
                          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                          sliver: SliverAppBar(
                            elevation: 0,
                            backgroundColor: Theme.of(context).primaryColor,
                            automaticallyImplyLeading: false,
                            pinned: true,
                            floating: true,
                            expandedHeight: 0,
                            surfaceTintColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).primaryColor,
                            forceElevated: innerBoxIsScrolled,
                            bottom: PreferredSize(
                              preferredSize: Size.fromHeight(_categoryTabBarHeight * revealT),
                              child: ClipRect(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  heightFactor: revealT,
                                  child: Opacity(
                                    opacity: revealT,
                                    child: (_tabController != null && _tabController!.length == expectedLength)
                                        ? TabBar(
                                      controller: _tabController,
                                      isScrollable: true,
                                      tabAlignment: TabAlignment.start,
                                      dividerColor: Colors.transparent,
                                      indicatorColor: Theme.of(context).colorScheme.secondary,
                                      labelStyle: titilliumSemiBold.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Dimensions.fontSizeSmall),
                                      unselectedLabelStyle: titilliumRegular.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeSmall),
                                      tabs: [
                                        Tab(text: getTranslated('explore', context)!),
                                        ...categories.map((c) => Tab(text: getTranslated(c.name, context) ?? c.name ?? ''),
                                        ),
                                      ],
                                    ) : const SizedBox(height: _categoryTabBarHeight),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverSearchBarDelegate(
                            visible: onExploreTab,
                            child: _searchBar(context),
                          ),
                        ),

                        if (onExploreTab) ...[
                          SliverToBoxAdapter(
                            child: ColoredBox(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Column(
                                children: [
                                  const SizedBox(height: Dimensions.paddingSizeOverLarge),
                                  const FlashDealSection(),
                                  const BannersSliderWidget(),
                                  const FeaturedProductsWidget(),
                                  ClearanceListWidget(),
                                  TodaysDealSectionWidget(),
                                  if (_isAuctionEnabled)
                                    AuctionProductSectionWidget(onSeeAll: widget.onAuctionSeeAll),
                                  const NewUserExclusiveSection(),
                                  if (!_singleVendor) const TopStoresWidget(),
                                  const BannersSliderWidget(useFooterBanners: true),
                                ],
                              ),
                            ),
                          ),

                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverTabBarDelegate(
                              height: 46,
                              stuckToSearch: true,
                              containerKey: _buttonsTabBarKey,
                              child: ButtonsTabBar(
                                isSticky: true,
                                controller: _productTabController!,
                                tabs: _productTypes.map((type) => type.displayName(context)).toList(),
                              ),
                            ),
                          ),

                        ],
                      ];
                    },

                    body: onExploreTab ? TabBarView(
                      controller: _productTabController,
                      children: _productTypes.map((type) => _ListItemWidget(productType: type)).toList(),
                    ) : _switchingToCategory ? const CategoryContentScreenShimmer() : TabBarView(
                      controller: _tabController,
                      children: [
                        const SizedBox(),
                        ...categories.asMap().entries.map((entry) => HomeCategoryContent(categoryName: entry.value.name ?? '', categoryIndex: entry.key),
                        ),
                      ],
                    ),


                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool visible;

  const _SliverSearchBarDelegate({
    required this.child,
    required this.visible,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => visible ? child : const SizedBox.shrink();

  @override
  double get maxExtent => visible ? 72 : 0;

  @override
  double get minExtent => visible ? 72 : 0;

  @override
  bool shouldRebuild(_SliverSearchBarDelegate oldDelegate) => oldDelegate.child != child || oldDelegate.visible != visible;
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final bool stuckToSearch;
  final Key? containerKey;

  const _SliverTabBarDelegate({
    required this.child,
    this.height = 52,
    this.stuckToSearch = false,
    this.containerKey,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      key: containerKey,
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: stuckToSearch ? 4 : 12),
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height ||
          oldDelegate.stuckToSearch != stuckToSearch || oldDelegate.containerKey != containerKey;
}

class _CustomizableSpaceBarWidget extends StatelessWidget {
  final Widget Function(BuildContext context, double scrollingRate, Widget? child) builder;
  final Widget? child;

  const _CustomizableSpaceBarWidget({required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
        final deltaExtent = settings.maxExtent - settings.minExtent;
        final scrollingRate = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);
        return builder(context, scrollingRate, child);
      },
    );
  }
}

class _ListItemWidget extends StatefulWidget {
  final ProductType productType;

  const _ListItemWidget({required this.productType});

  @override
  State<_ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<_ListItemWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).getProductsForTypeDebounced(widget.productType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductModel?>(
      selector: (_, controller) => controller.productModelForType(widget.productType),
      builder: (context, selectedProductModel, _) {
        final products = selectedProductModel?.products;

        if (products == null) {
          return const _ListItemShimmer();
        }

        if (products.isEmpty) {
          return NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_product_found', context) ?? '');
        }

        return Padding(
          padding: const EdgeInsets.all(11),
          child: MasonryGridView.count(
            cacheExtent: 600,
            key: PageStorageKey(widget.productType),
            crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
            itemCount: products.length,
            itemBuilder: (context, index) => RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: ProductCardWidget(key: ValueKey(products[index].id), product: products[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ListItemShimmer extends StatelessWidget {
  const _ListItemShimmer();

  // Mimic masonry stagger — alternating heights per column
  static const List<double> _imageHeights = [
    150, 120, 160, 110, 140, 130,
    125, 155, 115, 145, 135, 120,
  ];

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = ResponsiveHelper.isTab(context) ? 3 : 2;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: MasonryGridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        itemCount: _imageHeights.length,
        itemBuilder: (context, index) {
          final double imageHeight = _imageHeights[index];

          return Container(
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: ProductCardShimmerWidget(imageHeight: imageHeight),
          );
        },
      ),
    );
  }
}