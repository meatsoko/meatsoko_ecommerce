import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/category_content_screen_shimmer.dart';
import 'package:user_app/features/auth/controllers/auth_controller.dart';
import 'package:user_app/features/category/controllers/category_controller.dart';
import 'package:user_app/features/home/widgets/redesign/category_morph_header.dart';
import 'package:user_app/features/home/widgets/redesign/discover_near_you_widget.dart';
import 'package:user_app/features/home/widgets/redesign/home_category_content.dart';
import 'package:user_app/features/home/widgets/redesign/banner_slider_widget.dart';
import 'package:user_app/features/home/widgets/redesign/featured_products_widget.dart';
import 'package:user_app/features/home/widgets/redesign/flash_deal_section.dart';
import 'package:user_app/features/notification/controllers/notification_controller.dart';
import 'package:user_app/features/notification/domain/models/notification_model.dart';
import 'package:user_app/features/splash/controllers/splash_controller.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/app_constants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/brand_colors.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/utill/images.dart';
import 'package:provider/provider.dart';

class HomeExploreScreen extends StatefulWidget {
  final ValueListenable<int>? resetToExploreListenable;
  const HomeExploreScreen({super.key, this.resetToExploreListenable});

  @override
  State<HomeExploreScreen> createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, double> _tabScrollOffsets = {};
  bool _switchingToCategory = false;

  TabController? _tabController;

  final GlobalKey _nestedKey = GlobalKey();
  static const double _categoryTabBarHeight = 64;

  @override
  void initState() {
    super.initState();
    _initTabs();
    widget.resetToExploreListenable?.addListener(_resetToExplore);
  }

  void _resetToExplore() {
    if (_tabController != null && _tabController!.index != 0) {
      _tabController!.animateTo(0);
    }
  }

  Widget _searchBar(BuildContext context) {
    // Fixed height matching _SliverSearchBarDelegate.maxExtent/minExtent (72)
    // exactly — RenderSliverPinnedPersistentHeader derives its paintExtent
    // from this child's *actual measured height*, not from the delegate's
    // declared extent, so a mismatch here throws a SliverGeometry
    // ("layoutExtent exceeds paintExtent") layout error.
    return Container(
      height: 72,
      alignment: Alignment.center,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              onTap: () => RouterHelper.getCategoryScreenRoute(
                  action: RouteAction.push, focusSearch: true),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(children: [
                  Icon(Icons.search,
                      color: Theme.of(context).hintColor, size: 22),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      getTranslated('search_hint', context) ??
                          'Search for products...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: () => RouterHelper.getSearchRoute(action: RouteAction.push),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Icon(Icons.filter_list,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }

  int _scrollKeyForTab(int tabIndex) {
    if (tabIndex == 0) return -1;
    final categories =
        Provider.of<CategoryController>(context, listen: false).categoryList;
    return categories[tabIndex - 1].id ?? -1;
  }

  void _initTabs() {
    final categories =
        Provider.of<CategoryController>(context, listen: false).categoryList;
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
          _scrollController.jumpTo(_tabScrollOffsets[incomingKey] ?? 0.0);
        }
        final bool nowOnExplore = _tabController!.index == 0;
        final bool enteringCategory = _tabController!.indexIsChanging &&
            _tabController!.previousIndex == 0 &&
            _tabController!.index != 0;
        if (nowOnExplore != wasOnExplore ||
            enteringCategory != _switchingToCategory) {
          wasOnExplore = nowOnExplore;
          _switchingToCategory = enteringCategory;
          setState(() {});
        }
      });
    }

    setState(() {});
  }

  @override
  void dispose() {
    widget.resetToExploreListenable?.removeListener(_resetToExplore);
    _scrollController.dispose();
    _tabController?.dispose();
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

          if (_tabController == null ||
              _tabController!.length != expectedLength) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _initTabs());
          }

          final bool onExploreTab =
              _tabController == null || _tabController!.index == 0;

          final List<Widget> headerSlivers = [
            SliverAppBar(
              pinned: true,
              floating: false,
              elevation: 0,
              centerTitle: false,
              automaticallyImplyLeading: false,
              backgroundColor: BrandColors.burgundy,
              expandedHeight: 65,
              // toolbarHeight == expandedHeight so there's no collapse range
              // at all — FlexibleSpaceBar applies its own built-in fade to
              // `background` as it shrinks toward the toolbar height, which
              // fought with "always show the app bar content" even after
              // pinning it. With zero shrink range, that fade never
              // triggers, and FlexibleSpaceBar isn't needed for anything
              // else here (no parallax/stretch effects wanted).
              toolbarHeight: 65,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.homePagePadding,
                      vertical: Dimensions.paddingSizeSmall),
                  child: Builder(
                    builder: (context) {
                      final bool isLoggedIn =
                          Provider.of<AuthController>(context, listen: false)
                              .isLoggedIn();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppConstants.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titilliumBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          Consumer<NotificationController>(
                            builder: (context, notificationController, _) {
                              final bool isAuctionEnabled = Provider.of<
                                      SplashController>(context, listen: false)
                                  .configModel
                                  ?.isAuctionFeatureEnabled ==
                                  true;
                              final int unreadCount = isLoggedIn
                                  ? totalNewNotification(
                                      notificationController.notificationModel,
                                      notificationController
                                          .auctionNotificationModel,
                                      isAuctionEnabled: isAuctionEnabled,
                                    )
                                  : 0;
                              return GestureDetector(
                                onTap: () => RouterHelper.getNotificationRoute(
                                    action: RouteAction.push),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        Images.notification,
                                        height: 22,
                                        width: 22,
                                        color: Colors.white,
                                      ),
                                      if (unreadCount > 0)
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeExtraSmall),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            child: Text(
                                              unreadCount > 9
                                                  ? '9+'
                                                  : unreadCount.toString(),
                                              style: titilliumBold.copyWith(
                                                  fontSize: 8,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Not pinned: scrolls away normally like any other content.
            if (onExploreTab) SliverToBoxAdapter(child: _searchBar(context)),

            // Moved here (was after Flash Deal, below Categories) so the
            // on-screen order reads AppBar -> Search -> Banners -> Categories
            // -> ... -> Featured Products.
            if (onExploreTab) const SliverToBoxAdapter(child: BannersSliderWidget()),

            // Header for the Categories section below — formerly the
            // two-line "Fresh Cuts / delivered in minutes" hero text that
            // sat at the very top of the page; moved here and collapsed to
            // one line as the Categories section's own heading.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.homePagePadding)
                    .copyWith(top: Dimensions.paddingSizeSmall),
                child: Text(
                  getTranslated('CATEGORY', context) ?? 'Categories',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titilliumBold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeOverLarge,
                  ),
                ),
              ),
            ),

            // Not pinned, same reasoning as the search bar above — it still
            // morphs from grid to bar as it's scrolled past (the crossfade
            // is driven by shrinkOffset regardless of pinning), it just
            // keeps going and scrolls fully away afterwards instead of
            // sticking indefinitely.
            (_tabController != null && _tabController!.length == expectedLength)
                ? SliverPersistentHeader(
                    pinned: false,
                    delegate: CategoryMorphHeaderDelegate(
                      categories: categories,
                      tabController: _tabController!,
                      barExtent: _categoryTabBarHeight,
                    ),
                  )
                : SliverToBoxAdapter(
                    child: SizedBox(height: _categoryTabBarHeight)),

            if (onExploreTab) ...[
              SliverToBoxAdapter(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: const SizedBox(height: Dimensions.paddingSizeDefault),
                ),
              ),

              SliverToBoxAdapter(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    children: [
                      const DiscoverNearYouBody(),
                      const FlashDealSection(),
                      const FeaturedProductsWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ];

          // The Explore tab has no independently-scrolling body anymore (all
          // of its content lives in the header slivers above), so it uses a
          // single CustomScrollView. Using NestedScrollView here too — with
          // an empty SizedBox.shrink() as its body — used to leave a second,
          // essentially-content-free inner Scrollable that NestedScrollView
          // still had to coordinate scroll handoff with, which showed up as
          // extra scrollable empty space below the content and an odd
          // hand-off "scroll" when scrolling back up. Category tabs still
          // need NestedScrollView, since each one is its own independently
          // scrolling body switched via TabBarView while the headers stay put.
          final Widget scrollArea = onExploreTab
              ? CustomScrollView(
                  key: _nestedKey,
                  controller: _scrollController,
                  slivers: headerSlivers,
                )
              : NestedScrollView(
                  key: _nestedKey,
                  controller: _scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) =>
                      headerSlivers,
                  body: _switchingToCategory
                      ? const CategoryContentScreenShimmer()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            const SizedBox(),
                            ...categories.asMap().entries.map(
                                  (entry) => HomeCategoryContent(
                                      categoryName: entry.value.name ?? '',
                                      categoryIndex: entry.key),
                                ),
                          ],
                        ),
                );

          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              bottom: false,
              child: Scaffold(
                body: _tabController == null
                    ? const Center(child: CircularProgressIndicator())
                    : scrollArea,
              ),
            ),
          );
        },
      ),
    );
  }
}
