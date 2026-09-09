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
import 'package:user_app/features/profile/controllers/profile_contrroller.dart';
import 'package:user_app/features/splash/controllers/splash_controller.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/language_constrants.dart';
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
              onTap: () =>
                  RouterHelper.getCategoryScreenRoute(action: RouteAction.push),
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
              child: Icon(Icons.qr_code_scanner,
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
                  child: Consumer<ProfileController>(
                    builder: (context, profileController, _) {
                      final bool isLoggedIn =
                          Provider.of<AuthController>(context, listen: false)
                              .isLoggedIn();
                      final String firstLine = isLoggedIn
                          ? getTranslated('welcome', context)!
                          : getTranslated('hello', context)!;
                      final String secondLine = isLoggedIn
                          ? (profileController.userInfoModel?.fName ?? '')
                          : getTranslated('welcome', context)!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  firstLine,
                                  style: titilliumRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        Dimensions.paddingSizeExtraExtraSmall),
                                Text(
                                  secondLine,
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.homePagePadding)
                    .copyWith(top: Dimensions.paddingSizeSmall),
                child: RichText(
                  text: TextSpan(
                    style: titilliumBold.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: Dimensions.fontSizeOverLarge,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                          text:
                              '${getTranslated('Fresh Cuts', context) ?? 'Fresh cuts,'}\n'),
                      TextSpan(
                        text: getTranslated('delivered in minutes', context) ??
                            'delivered fast.',
                        style: const TextStyle(color: BrandColors.burgundy),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Not pinned: scrolls away normally like any other content, so
            // the only things that stay stuck on screen are the app bar and
            // (once you've scrolled to it) the Discover Near You header.
            if (onExploreTab) SliverToBoxAdapter(child: _searchBar(context)),

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

              // Fixed-size, always small — this is the *resting* state.
              // Sliver headers always render at maxExtent the moment they
              // first appear (before any of their own local scrolling has
              // happened), so a delegate with a "magnified" maxExtent would
              // show magnified by default, which is wrong here — this
              // element should read as a normal small heading until (and
              // unless) the separate _DiscoverMagnifyOverlay below takes
              // over. No shrink range at all, so there's no geometry risk.
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverSmallDiscoverHeaderDelegate(
                    scrollController: _scrollController),
              ),

              SliverToBoxAdapter(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    children: [
                      // Always in its normal spot (never hidden/duplicated)
                      // — it just grows taller while the magnify overlay
                      // above is active, via heightBoost tied to the same
                      // scroll-linked t, and settles back to its normal
                      // size once that ends.
                      AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, _) {
                          final double offset = _scrollController.hasClients
                              ? _scrollController.offset
                              : 0.0;
                          final double t =
                              _DiscoverMagnifyOverlay.progressFor(offset);
                          return DiscoverNearYouBody(heightBoost: t * 180);
                        },
                      ),
                      const FlashDealSection(),
                      const BannersSliderWidget(),
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
              ? Stack(
                  children: [
                    CustomScrollView(
                      key: _nestedKey,
                      controller: _scrollController,
                      slivers: headerSlivers,
                    ),
                    Positioned(
                      top: 65,
                      left: 0,
                      right: 0,
                      child: _DiscoverMagnifyOverlay(
                          scrollController: _scrollController),
                    ),
                  ],
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

/// Fixed-size resting state for the "Discover Near You" heading — always
/// small, bold, left-aligned, opaque. No shrink range (minExtent ==
/// maxExtent), so there's no sliver-geometry risk at all; the magnify
/// animation lives entirely in [_DiscoverMagnifyOverlay] instead, layered
/// on top independently of this sliver's own layout.
///
/// Listens to the same [scrollController] as the overlay purely to know
/// when to hide its own text — while the overlay is showing the magnified
/// version, this one renders nothing (its 48px slot stays reserved in the
/// layout, just empty) so the two are never both visible at once.
class _SliverSmallDiscoverHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final ScrollController scrollController;

  const _SliverSmallDiscoverHeaderDelegate({required this.scrollController});

  static const double _extent = 48;
  static const double _fontSize = 14;

  @override
  double get maxExtent => _extent;

  @override
  double get minExtent => _extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final double offset =
            scrollController.hasClients ? scrollController.offset : 0.0;
        final bool magnifyActive = _DiscoverMagnifyOverlay.isActive(offset);

        return Container(
          height: _extent,
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.homePagePadding),
          alignment: Alignment.centerLeft,
          child: magnifyActive
              ? null
              : Text(
                  getTranslated('discover_near_you', context) ??
                      'Discover Near You',
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titilliumBold.copyWith(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(
          covariant _SliverSmallDiscoverHeaderDelegate oldDelegate) =>
      false;
}

/// Splits "Discover Near You" onto two lines (on its first space — matches
/// the current English copy) rather than relying on wrap, so it always
/// reads as two lines regardless of how wide the available space is.
class _TwoLineDiscoverText extends StatelessWidget {
  final double fontSize;

  const _TwoLineDiscoverText({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final String full =
        getTranslated('discover_near_you', context) ?? 'Discover Near You';
    final int splitAt = full.indexOf(' ');
    final String line1 = splitAt == -1 ? full : full.substring(0, splitAt);
    final String line2 = splitAt == -1 ? '' : full.substring(splitAt + 1);
    final TextStyle style = titilliumBold.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1.05,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(line1, textAlign: TextAlign.left, style: style),
        if (line2.isNotEmpty)
          Text(line2, textAlign: TextAlign.left, style: style),
      ],
    );
  }
}

/// The actual "small at rest -> grows to fill the fading grid's space ->
/// shrinks back to small" animation, tied directly to
/// [ScrollController.offset] via [AnimatedBuilder] (not the sliver
/// shrinkOffset trick — that always starts at its maximum size the moment
/// it first appears, which can't produce a curve that's small at both ends
/// with a magnified peak in between).
///
/// This is a decorative overlay, layered on top of the scroll view rather
/// than living inside the sliver list. It only renders (t > 0) during the
/// scroll window where the category grid is fading away underneath it —
/// outside that window it's entirely absent, so it never covers the
/// headline, search bar, or the small pinned heading above.
///
/// Deliberately simple: this used to also try to measure the real
/// carousel's on-screen position (via RenderBox lookups) and grow an
/// embedded copy of it to exactly fill the gap down to that point. That
/// added a lot of fragile machinery for a result that was hard to verify
/// without live testing and never looked right — the real carousel now
/// just grows in its own normal spot instead (see the AnimatedBuilder
/// around DiscoverNearYouBody above), and this overlay only needs to be
/// tall enough for its own text plus a fixed, small margin below it.
///
/// The three offsets below are estimates (this app's exact header heights
/// weren't measured live) for *when* this activates — if the peak feels
/// early/late once you see it scrolling, these are the numbers to adjust.
class _DiscoverMagnifyOverlay extends StatelessWidget {
  final ScrollController scrollController;

  const _DiscoverMagnifyOverlay({required this.scrollController});

  static const double _fadeInStart = 220; // grid starts fading here
  static const double _peakOffset =
      340; // grid fully faded, text at its biggest
  static const double _fadeOutEnd = 460; // small pinned header takes over

  static const double _smallFontSize = 14;
  static const double _magnifiedFontSize = 44;
  // How much space is left below the text — the only thing this overlay's
  // height is based on now.
  static const double _bottomMargin = 20;

  static bool isActive(double offset) =>
      offset > _fadeInStart && offset < _fadeOutEnd;

  static double progressFor(double offset) {
    if (offset <= _fadeInStart || offset >= _fadeOutEnd) return 0.0;
    final double t = offset <= _peakOffset
        ? (offset - _fadeInStart) / (_peakOffset - _fadeInStart)
        : (_fadeOutEnd - offset) / (_fadeOutEnd - _peakOffset);
    return t.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final double offset =
            scrollController.hasClients ? scrollController.offset : 0.0;
        final double t = progressFor(offset);

        if (t <= 0.0) return const SizedBox.shrink();

        final double fontSize =
            _smallFontSize + (t * (_magnifiedFontSize - _smallFontSize));
        final double textHeight = fontSize * 1.05 * 2; // two lines
        final double height =
            Dimensions.paddingSizeLarge + textHeight + _bottomMargin;

        return IgnorePointer(
          child: Container(
            height: height,
            width: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.only(
              left: Dimensions.homePagePadding,
              right: Dimensions.homePagePadding,
              top: Dimensions.paddingSizeLarge,
            ),
            alignment: Alignment.topLeft,
            child: _TwoLineDiscoverText(fontSize: fontSize),
          ),
        );
      },
    );
  }
}
