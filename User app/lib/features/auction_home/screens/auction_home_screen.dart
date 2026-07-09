import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/controllers/auction_category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/controllers/auction_home_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/screens/category_content_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/screens/explore_content_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AuctionHomeScreen extends StatefulWidget {
  final ValueListenable<int>? resetToExploreListenable;
  const AuctionHomeScreen({super.key, this.resetToExploreListenable});

  @override
  State<AuctionHomeScreen> createState() => _AuctionHomeScreenState();
}

class _AuctionHomeScreenState extends State<AuctionHomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  TabController? _tabController;
  final Map<int, double> _tabScrollOffsets = {};
  bool _isViewAllTabSwitch = false;

  @override
  void initState() {
    super.initState();
    _initTabs();
    widget.resetToExploreListenable?.addListener(_resetToExplore);
  }

  void _resetToExplore() {
    if (_tabController != null && _tabController!.index != 0) {
      _animateToTab(0);
    }
  }

  Future<void> _refreshData() async {
    _tabScrollOffsets.clear();
    await Future.wait([
      Provider.of<AuctionCategoryController>(context, listen: false).getCategoryList(true),
      Provider.of<AuctionHomeController>(context, listen: false).getAllAuctionHomeSections(),
      Provider.of<AuctionHomeController>(context, listen: false).getRecentlyViewedAuctionList(isUpdate: false, isLoggedIn: Provider.of<AuthController>(context, listen: false).isLoggedIn()),
    ]);
    final categories = Provider.of<AuctionCategoryController>(context, listen: false).categoryList;
    for (final category in categories) {
      Provider.of<AuctionCategoryController>(context, listen: false).getCategoryProducts(category.id!, 1);
    }
    _initTabs();
  }

  int _scrollKeyForTab(int tabIndex) {
    if (tabIndex == 0) return -1;
    final categories = Provider.of<AuctionCategoryController>(context, listen: false).categoryList;
    return categories[tabIndex - 1].id ?? -1;
  }

  void _initTabs() {
    final categories = Provider.of<AuctionCategoryController>(context, listen: false).categoryList;
    final tabCount = 1 + categories.length;

    if (_tabController == null || _tabController!.length != tabCount) {
      _tabController?.dispose();
      _tabController = TabController(length: tabCount, vsync: this);

      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) {
          _isViewAllTabSwitch = true;
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) setState(() => _isViewAllTabSwitch = false);
          });
          final previousKey = _scrollKeyForTab(_tabController!.previousIndex);
          final incomingKey = _scrollKeyForTab(_tabController!.index);
          _tabScrollOffsets[previousKey] = _scrollController.offset;
          _scrollController.jumpTo(_tabScrollOffsets[incomingKey] ?? 0.0);
        }
        setState(() {});
      });
    }
    setState(() {});
  }

  void _animateToTab(int index) {
    _isViewAllTabSwitch = true;
    _tabController?.animateTo(index);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isViewAllTabSwitch = false);
    });
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
          _animateToTab(0);
          return true;
        }
        return false;
      },
      child: Consumer<AuctionCategoryController>(
        builder: (context, auctionCategoryController, _) {
          final categories = auctionCategoryController.categoryList;

          final expectedLength = 1 + categories.length;
          if (_tabController == null || _tabController!.length != expectedLength) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _initTabs());
          }

          return Container(
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              bottom: false,
              child: Scaffold(
                body: _tabController == null
                    ? const Center(child: CircularProgressIndicator())
                    : NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [

                        SliverAppBar(
                          floating: false,
                          elevation: 0,
                          centerTitle: false,
                          automaticallyImplyLeading: false,
                          backgroundColor: Theme.of(context).primaryColor,
                          expandedHeight: 70,
                          flexibleSpace: _CustomizableSpaceBarWidget(
                            builder: (ctx, scrollingRate) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.homePagePadding),
                                child: Opacity(
                                  opacity: (1 - scrollingRate).clamp(0.0, 1.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Consumer<ProfileController>(
                                          builder: (context, profileController, _) {
                                            final bool isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(getTranslated('welcome_to', context)!,
                                                      style: titilliumRegular.copyWith(
                                                        color: Colors.white,
                                                        fontSize: Dimensions.fontSizeDefault,
                                                      ),
                                                    ),
                                                    if (isLoggedIn) ...[
                                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraExtraSmall),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).cardColor,
                                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                        ),
                                                        child: Text(getTranslated('auction', context)!,
                                                          style: titilliumBold.copyWith(
                                                            fontSize: Dimensions.fontSizeSmall,
                                                            color: Theme.of(context).colorScheme.tertiary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                                                isLoggedIn
                                                    ? Text(
                                                        profileController.userInfoModel?.fName ?? '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: titilliumBold.copyWith(
                                                          color: Colors.white,
                                                          fontSize: Dimensions.fontSizeLarge,
                                                        ),
                                                      )
                                                    : Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraExtraSmall),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).cardColor,
                                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                        ),
                                                        child: Text(getTranslated('auction', context)!,
                                                          style: titilliumBold.copyWith(
                                                            fontSize: Dimensions.fontSizeSmall,
                                                            color: Theme.of(context).colorScheme.tertiary,
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      Consumer<ProfileController>(
                                        builder: (context, profileController, _) =>
                                            GestureDetector(
                                              onTap: () => RouterHelper.getMoreScreenRoute(action: RouteAction.push),
                                              child: ClipOval(
                                                child: CustomImageWidget(
                                                  image: profileController.userInfoModel?.imageFullUrl?.path ?? '',
                                                  width: 40, height: 40,
                                                  placeholder: Images.guestProfile,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
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
                              bottom: (_tabController != null && _tabController!.length == expectedLength)
                                  ? TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                dividerColor: Colors.transparent,
                                indicatorColor: Theme.of(context).colorScheme.secondary,
                                labelStyle: titilliumSemiBold.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                                unselectedLabelStyle: titilliumRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                                tabs: [
                                  Tab(text: getTranslated('explore', context)!),

                                  ...categories.map((c) => Tab(text: getTranslated(c.name, context) ?? c.name ?? ''),
                                  ),
                                ],
                              ) : PreferredSize(preferredSize: const Size.fromHeight(48), child: const SizedBox())
                          ),
                        ),

                        if (_tabController != null && _tabController!.index == 0)
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverSearchBarDelegate(
                              child: Container(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                child: InkWell(
                                  onTap: () => RouterHelper.getAuctionSearchScreenRoute(action: RouteAction.push),
                                  child: SearchHomePageWidget(isFormAuction: true))
                              ),
                            ),
                          ),
                      ];
                    },

                    body: TabBarView(controller: _tabController,
                      children: [
                        Builder(
                          builder: (context) => Builder(
                            builder: (context) {
                              return RefreshIndicator(
                                onRefresh: () async => _refreshData(),
                                child: CustomScrollView(
                                  slivers: [
                                    SliverOverlapInjector(
                                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                                    ),
                                    ExploreContent(
                                      onCategoryViewAll: (categoryId) {
                                        final categories = Provider.of<AuctionCategoryController>(context, listen: false).categoryList;

                                        final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
                                        if (categoryIndex != -1) {
                                          _animateToTab(1 + categoryIndex);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),

                      ...categories.map((c) => CategoryContent(categoryName: c.name ?? '', categoryId: c.id!),
                      ),
                    ],
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
  final double height;

  const _SliverSearchBarDelegate({required this.child, this.height = 75});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;


  @override
  bool shouldRebuild(_SliverSearchBarDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}

class _CustomizableSpaceBarWidget extends StatelessWidget {
  final Widget Function(BuildContext context, double scrollingRate) builder;

  const _CustomizableSpaceBarWidget({required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
        final deltaExtent = settings.maxExtent - settings.minExtent;
        final scrollingRate =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);
        return builder(context, scrollingRate);
      },
    );
  }
}