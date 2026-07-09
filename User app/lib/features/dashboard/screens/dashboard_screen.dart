import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_feature_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/screens/my_auction_activity_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/screens/my_bids_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/controllers/auction_category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/screens/auction_category_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/controllers/auction_home_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/screens/auction_home_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/screens/cart_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/screens/category_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/screens/home_explore_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/restock/controllers/restock_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/controllers/search_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/network_info.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/widgets/app_exit_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/screens/aster_theme_home_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/screens/fashion_theme_home_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/screens/order_screen.dart';
import 'package:provider/provider.dart';

enum AppMode { main, auction }

class DashBoardScreen extends StatefulWidget {
  final int? pageIndex;
  const DashBoardScreen({super.key, required this.pageIndex});
  @override
  DashBoardScreenState createState() => DashBoardScreenState();
}

class DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  final PageStorageBucket bucket = PageStorageBucket();

  bool singleVendor = false;

  AppMode _currentMode = AppMode.main;
  int _selectedIndex = 0;
  bool isAuctionEnabled = false;

  late List<Widget> _mainScreens;
  late List<Widget> _auctionScreens;
  late final ValueNotifier<bool> _loginNotifier;

  final ValueNotifier<int> _homeResetNotifier = ValueNotifier(0);
  final ValueNotifier<int> _auctionResetNotifier = ValueNotifier(0);

  static const Duration _auctionBannerCooldown = Duration(minutes : 2);
  Timer? _auctionBannerCooldownTimer;
  bool _auctionBannerOnCooldown = false;

  bool _checkIsLoggedIn() =>
      Provider.of<AuthController>(context, listen: false).isLoggedIn();

  void refreshLoginStatus() {
    log("===Refresh Login Status===");
    _loginNotifier.value = _checkIsLoggedIn();
  }

  @override
  void initState() {
    super.initState();
    _loginNotifier = ValueNotifier(_checkIsLoggedIn());

    Provider.of<FlashDealController>(context, listen: false).getFlashDealList(true, false);
    Provider.of<SplashController>(context, listen: false).getBusinessPagesList('default');
    Provider.of<SplashController>(context, listen: false).getBusinessPagesList('pages');
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<CartController>(context, listen: false).mergeGuestCart();
      Provider.of<WishListController>(context, listen: false).getWishList('');
      Provider.of<ChatController>(context, listen: false).getChatList(1, reload: false, userType: 0);
      Provider.of<ChatController>(context, listen: false).getChatList(1, reload: false, userType: 1);
      Provider.of<RestockController>(context, listen: false).getRestockProductList(1, getAll: true);
      Provider.of<WalletController>(context, listen: false).getTransactionList(1, isUpdate: false);
    }

    final SplashController splashController = Provider.of<SplashController>(context, listen: false);
    isAuctionEnabled = splashController.configModel?.isAuctionFeatureEnabled ?? false;
    singleVendor = splashController.configModel?.businessMode == "single";
    Provider.of<SearchProductController>(context, listen: false).getAuthorList(null);
    Provider.of<SearchProductController>(context, listen: false).getPublishingHouseList(null);

    if (splashController.configModel?.activeTheme == "default") {
      // HomePage.loadData(false);
    } else if (splashController.configModel?.activeTheme == "theme_aster") {
      AsterThemeHomeScreen.loadData(false);
    } else {
      FashionThemeHomePage.loadData(false);
    }

    // final Widget homeScreen = (splashController.configModel?.activeTheme == "default")
    //   ? const HomePage()
    //   : (splashController.configModel?.activeTheme == "theme_aster")
    //     ? const AsterThemeHomeScreen()
    //     : const HomePage();

    final Widget homeScreen = HomeExploreScreen(
      resetToExploreListenable: _homeResetNotifier,
      onAuctionSeeAll: () {
        setState(() {
          _currentMode = AppMode.auction;
          _selectedIndex = 4;
        });
      },
    );

    _mainScreens = [
      homeScreen,
      const CategoryScreen(isBacButtonExist: false),
      const CartScreen(showBackButton: false, fromDashboard: true),
      OrderScreen(
        isBacButtonExist: false,
        fromDashboard: true,
        loginNotifier: _loginNotifier,
        onLoginSuccess: () => setState(() {
          _currentMode = AppMode.main;
          _selectedIndex = 3;
        }),
      ),
      const SizedBox.shrink(),
    ];

    _auctionScreens = [
      const SizedBox.shrink(),
      MyAuctionActivityScreen(
        isBackButtonExist: false,
        fromDashboard: true,
        loginNotifier: _loginNotifier,
        onLoginSuccess: () => setState(() {
          _currentMode = AppMode.auction;
          _selectedIndex = 1;
        }),
      ),
      MyBidsScreen(
        showBackButton: false,
        fromDashboard: true,
        loginNotifier: _loginNotifier,
        onLoginSuccess: () => setState(() {
          _currentMode = AppMode.auction;
          _selectedIndex = 2;
        }),
      ),
      const AuctionCategoryScreen(isBacButtonExist: false),
      AuctionHomeScreen(resetToExploreListenable: _auctionResetNotifier)
    ];

    if (widget.pageIndex == 4) {
      _currentMode = AppMode.auction;
      _selectedIndex = 4;
    } else if (widget.pageIndex == 6) {
      _currentMode = AppMode.auction;
      _selectedIndex = 2;
    } else if (widget.pageIndex != null && widget.pageIndex! < _mainScreens.length) {
      _selectedIndex = widget.pageIndex!;
    }

    NetworkInfo.checkConnectivity(context);

    _loadHomeData();

    if (_currentMode == AppMode.auction) {
      _loadAuctionData();
    }
  }

  void _startAuctionBannerCooldown() {
    _auctionBannerOnCooldown = true;
    _auctionBannerCooldownTimer?.cancel();
    _auctionBannerCooldownTimer = Timer(_auctionBannerCooldown, () {
      _auctionBannerOnCooldown = false;
    });
  }

  @override
  void dispose() {
    _auctionBannerCooldownTimer?.cancel();
    _loginNotifier.dispose();
    _homeResetNotifier.dispose();
    _auctionResetNotifier.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    refreshLoginStatus();

    setState(() {
      if (_currentMode == AppMode.main) {
        if (index == 4 && isAuctionEnabled) {
          _currentMode = AppMode.auction;
          _selectedIndex = 4;
          // Select the tab first; load data after this frame is painted so the
          // selection animates instantly instead of waiting on the fetch.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadAuctionData();
          });
          if (AppConstants.demo && !_auctionBannerOnCooldown) {
            _startAuctionBannerCooldown();
            Future.delayed(const Duration(milliseconds: 350), () {
              if (mounted) {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierLabel: 'Auction Feature',
                  barrierColor: Colors.black54,
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (_, __, ___) => AuctionFeatureBannerWidget(
                    onGetItNow: () async {
                      SplashController splashController = Provider.of<SplashController>(Get.context!, listen: false);

                      final uri = Uri.parse(splashController.configModel?.auctionPromotionalPopupLink ?? '' );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  transitionBuilder: (_, animation, __, child) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(curved),
                        child: child,
                      ),
                    );
                  },
                );
              }
            });
          }
        } else if (index != 4) {
          if (index == 0) _homeResetNotifier.value++;
          _selectedIndex = index;
        }
      } else {
        if (index == 0) {
          _currentMode = AppMode.main;
          _selectedIndex = 0;
        } else {
          if (index == 4) _auctionResetNotifier.value++;
          _selectedIndex = index;
        }
      }
    });
  }

  Future<void> _loadHomeData() async {
    await Future.wait([
      Provider.of<ProfileController>(context, listen: false).getUserInfo(context, isLoggedIn: Provider.of<AuthController>(context, listen: false).isLoggedIn()),
      Provider.of<CategoryController>(context, listen: false).fetchWithCache(),
      Provider.of<BannerController>(context, listen: false).fetchWithCache(),
      Provider.of<FeaturedDealController>(context, listen: false).fetchWithCache(),
      Provider.of<ProductController>(context, listen: false).loadHomeDataWithCache(),
      Provider.of<ShopController>(context, listen: false).fetchWithCache(),
    ]);
  }

  Future<void> _loadAuctionData() async {
    await Future.wait([
      Provider.of<AuctionHomeController>(context, listen: false).fetchWithCache(isLoggedIn: Provider.of<AuthController>(context, listen: false).isLoggedIn()),
      Provider.of<AuctionCategoryController>(context, listen: false).fetchWithCache(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _currentMode == AppMode.main ? Theme.of(context).primaryColor : Colors.orange;

    final screens =
    _currentMode == AppMode.main ? _mainScreens : _auctionScreens;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (_currentMode == AppMode.auction) {
          if (_selectedIndex != 4) {
            _onItemTapped(4);
          } else {
            // From auction home, back returns to main mode instead of exiting.
            _onItemTapped(0);
          }
          return;
        }

        if (_selectedIndex != 0) {
          _onItemTapped(0);
          return;
        }

        if (context.mounted) {
          showModalBottomSheet(backgroundColor: Colors.transparent, context: Get.context!, builder: (_) => const AppExitCard());
        }
      },

      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        body: PageStorage(
          bucket: bucket,
          child: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
        ),
        bottomNavigationBar: ElevatedNavBar(
          currentMode: _currentMode,
          selectedIndex: _selectedIndex,
          activeColor: activeColor,
          isAuctionEnabled: isAuctionEnabled,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

}

class ElevatedNavBar extends StatelessWidget {
  final AppMode currentMode;
  final int selectedIndex;
  final Color activeColor;
  final ValueChanged<int> onItemTapped;
  final bool isAuctionEnabled;

  const ElevatedNavBar({
    super.key,
    required this.currentMode,
    required this.selectedIndex,
    required this.activeColor,
    required this.onItemTapped,
    required this.isAuctionEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final bool dividerOnRight = currentMode == AppMode.main ? !isRtl : isRtl;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.03),
              offset: const Offset(-2, 0),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: ColoredBox(
          color: ColorHelper.blendColors(Theme.of(context).scaffoldBackgroundColor, Colors.black, 0.12),
          child: SizedBox(
            height: 60,
            child: Stack(
            children: [
              if (isAuctionEnabled)
              Positioned(
                top: 0,
                bottom: 0,
                left: dividerOnRight ? null : 0,
                right: dividerOnRight ? 0 : null,
                width: 72,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ColorHelper.blendColors(Theme.of(context).scaffoldBackgroundColor, Colors.black, 0.12),
                    borderRadius: BorderRadius.only(
                      topLeft: dividerOnRight ? Radius.zero : const Radius.circular(10),
                      topRight: dividerOnRight ? const Radius.circular(10) : Radius.zero,
                    ),
                  ),
                  child: currentMode == AppMode.main ? _plainNavItem(icon: Images.navAuctionIcon, index: 4) : _plainNavItem(icon: Images.navCartIcon, index: 0),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  alignment: !isAuctionEnabled
                      ? Alignment.center
                      : dividerOnRight
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    width: isAuctionEnabled ? MediaQuery.of(context).size.width - 72 : MediaQuery.of(context).size.width,
                    child: ElevatedCard(
                      currentMode: currentMode,
                      selectedIndex: selectedIndex,
                      activeColor: activeColor,
                      onItemTapped: onItemTapped,
                      isAuctionEnabled: isAuctionEnabled,
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
    );
  }

  Widget _plainNavItem({
    required String icon,
    required int index,
  }) {
    final color = Colors.grey.shade500;

    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomAssetImageWidget(icon, color: color, height: 22),
        ],
      ),
    );
  }
}

class ElevatedCard extends StatelessWidget {
  final AppMode currentMode;
  final int selectedIndex;
  final Color activeColor;
  final bool isAuctionEnabled;
  final ValueChanged<int> onItemTapped;

  const ElevatedCard({super.key,
    required this.currentMode,
    required this.selectedIndex,
    required this.activeColor,
    required this.isAuctionEnabled,
    required this.onItemTapped,
  });



  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final bool dividerOnRight = currentMode == AppMode.main ? !isRtl : isRtl;
    final bool roundBottomLeft = isAuctionEnabled && !dividerOnRight;
    final bool roundBottomRight = isAuctionEnabled && dividerOnRight;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft: roundBottomLeft ? const Radius.circular(10) : Radius.zero,
          bottomRight: roundBottomRight ? const Radius.circular(10) : Radius.zero,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              axisAlignment: -1.0,
              child: child,
            );
          },
          child: currentMode == AppMode.main
              ? Row(
                  key: const ValueKey('main_menus'),
                  children: [
                    NavItem(
                        icon: Images.navHomeIcon,
                        label: getTranslated('ecom', context) ?? 'eCom',
                        index: 0,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped),
                    NavItem(
                        icon: Images.navCategoryIcon,
                        label: getTranslated('category', context) ?? 'Category',
                        index: 1,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped),
                    NavItem(
                        icon: Images.navCartIcon,
                        label: getTranslated('cart', context) ?? 'Cart',
                        index: 2,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped),
                    NavItem(
                        icon: Images.navOrderIcon,
                        label: getTranslated('orders', context) ?? 'Orders',
                        index: 3,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped),
                  ],
                )
              : Row(
                  key: const ValueKey('auction_menus'),
                  children: [
                    NavItem(
                        icon: Images.navActivityIcon,
                        label: getTranslated('my_activity', context) ?? 'My Activity',
                        index: 1,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped),
                    NavItem(
                        icon: Images.navBidIcon,
                        label: getTranslated('my_bid', context) ?? 'My Bid',
                        index: 2,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped),
                    NavItem(
                        icon: Images.navAuctionCategoryIcon,
                        label: getTranslated('category', context) ?? 'Category',
                        index: 3,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped),
                    NavItem(
                        icon: Images.navAuctionIcon,
                        label: getTranslated('auction', context) ?? 'Auction',
                        index: 4,
                        selectedIndex: selectedIndex,
                        onTap: onItemTapped),
                  ],
                ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    return Expanded(
      flex: isSelected ? 4 : 2,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: isSelected ? const Duration(milliseconds: 250) : Duration.zero,
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? Dimensions.paddingSizeTwelve : Dimensions.paddingSizeEight,
              vertical: isSelected ? Dimensions.paddingSizeEight : Dimensions.paddingSizeExtraSmall,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(mainAxisSize: MainAxisSize.min,
              children: [
                CustomAssetImageWidget(
                  icon,
                  height: isSelected ? Dimensions.paddingSizeDefaultAddress : Dimensions.paddingSizeLarge,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
                if (isSelected)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: Dimensions.paddingSizeExtraSmall),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          label,
                          style: textBold.copyWith(
                            fontSize: Dimensions.paddingSizeSmall,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
