import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/custom_asset_image_widget.dart';
import 'package:user_app/common/basewidget/custom_image_widget.dart';
import 'package:user_app/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:user_app/features/auction_dashboard_summary/controllers/auction_dashboard_summary_controller.dart';
import 'package:user_app/features/auth/controllers/auth_controller.dart';
import 'package:user_app/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:user_app/features/notification/controllers/notification_controller.dart';
import 'package:user_app/features/notification/domain/models/notification_model.dart';
import 'package:user_app/features/profile/controllers/profile_contrroller.dart';
import 'package:user_app/features/splash/controllers/splash_controller.dart';
import 'package:user_app/features/splash/domain/models/business_pages_model.dart';
import 'package:user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:user_app/helper/price_converter.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/brand_colors.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/utill/images.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MoreScreenView extends StatefulWidget {
  // When embedded as a persistent dashboard tab there's no pushed route to pop
  // back to — back-button handling is owned by DashBoardScreen's own PopScope.
  final bool fromDashboard;
  const MoreScreenView({super.key, this.fromDashboard = false});

  @override
  State<MoreScreenView> createState() => _MoreScreenViewState();
}

class _MoreScreenViewState extends State<MoreScreenView> {
  bool _wasLoggedIn = false;

  late AuthController _authController;

  @override
  void initState() {
    super.initState();

    _authController = Provider.of<AuthController>(context, listen: false);
    _wasLoggedIn = _authController.isLoggedIn();
    _authController.addListener(_onAuthStateChanged);
    final notificationController = Provider.of<NotificationController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authController.isLoggedIn()) {
        Provider.of<ProfileController>(context, listen: false).getUserInfo(context, isLoggedIn: true);
        Provider.of<WalletController>(context, listen: false).getTransactionList(1);
        Provider.of<AuctionDashboardSummaryController>(context, listen: false).getAuctionDashboardSummary(context);
        notificationController.getNotificationList(1);
        notificationController.getAuctionNotificationList(1);
      }
    });
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    final isNowLoggedIn = _authController.isLoggedIn();
    if (isNowLoggedIn && !_wasLoggedIn) {
      _wasLoggedIn = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onLoginSuccess();
      });
    } else if (!isNowLoggedIn) {
      _wasLoggedIn = false;
    }
  }

  void _onLoginSuccess() {
    if (!mounted) return;
    setState(() {});
    Provider.of<ProfileController>(context, listen: false).getUserInfo(context, isLoggedIn: true);
    Provider.of<WalletController>(context, listen: false).getTransactionList(1);
    Provider.of<AuctionDashboardSummaryController>(context, listen: false).getAuctionDashboardSummary(context);
  }

  BusinessPageModel? _getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    if (pagesList == null || pagesList.isEmpty) return null;
    for (final page in pagesList) {
      if (page.slug == slug) return page;
    }
    return null;
  }

  static Widget _buildNotificationBadge() {
    return Consumer2<AuthController, NotificationController>(
      builder: (context, authController, notificationController, _) {
        if (!authController.isLoggedIn()) return const SizedBox.shrink();
        final count = totalNewNotification(
          notificationController.notificationModel,
          notificationController.auctionNotificationModel,
          isAuctionEnabled: (Provider.of<SplashController>(context, listen: false).configModel?.isAuctionFeatureEnabled == true) ||
              (Provider.of<ProfileController>(context, listen: false).userInfoModel?.showAuctionMenuForUser == true),
        );
        if (count == 0) return const SizedBox.shrink();
        return RailBadge(count.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final splashController = Provider.of<SplashController>(context, listen: false);
    final authController = Provider.of<AuthController>(context);
    final summaryModel = Provider.of<AuctionDashboardSummaryController>(context).summaryModel;
    final isLoggedIn = authController.isLoggedIn();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !widget.fromDashboard) context.pop();
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: widget.fromDashboard ? Dimensions.paddingSizeDefault : 0,
        title: Text(
          getTranslated('profile', context) ?? 'Profile',
          style: titilliumBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        leading: widget.fromDashboard
            ? null
            : IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: Dimensions.iconSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Consumer<ProfileController>(
                          builder: (context, profileController, _) {
                            final user = profileController.userInfoModel;
                            final fullName = '${user?.fName ?? ''} ${user?.lName ?? ''}'.trim();
                            return GestureDetector(
                              onTap: () {
                                if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                  RouterHelper.getLoginRoute(
                                    action: RouteAction.push,
                                    fromPage: RouterHelper.moreScreen,
                                  );
                                } else {
                                  context.push(RouterHelper.profileScreen1);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeOverLarge,
                                ),
                                decoration: const BoxDecoration(
                                  color: BrandColors.burgundy,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(Dimensions.radiusLarge),
                                    bottomRight: Radius.circular(Dimensions.radiusLarge),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: CustomImageWidget(
                                        image: user?.imageFullUrl?.path ?? '',
                                        width: 76, height: 76,
                                        placeholder: Images.guestProfile,
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeDefault),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fullName.isEmpty ? (getTranslated('guest', context) ?? 'Guest') : fullName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: titilliumBold.copyWith(
                                              fontSize: Dimensions.fontSizeOverLarge,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                            Text(
                                              user.phone!,
                                              style: titilliumRegular.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                                color: Colors.white.withValues(alpha: 0.85),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Address quick-action card disabled for now — re-enable by
                        // uncommenting, and restore the taller spacer below it that
                        // was sized to clear this card's height.
                        // Positioned(
                        //   left: Dimensions.paddingSizeDefault,
                        //   right: Dimensions.paddingSizeDefault,
                        //   bottom: -Dimensions.paddingSizeExtraLarge,
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                        //     decoration: BoxDecoration(
                        //       color: Theme.of(context).cardColor,
                        //       borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                        //           blurRadius: 12,
                        //           offset: const Offset(0, 4),
                        //         ),
                        //       ],
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Expanded(
                        //           child: QuickActionItem(
                        //             iconImage: Images.address,
                        //             label: getTranslated('address', context) ?? 'Address',
                        //             onTap: () => context.push(RouterHelper.addressScreen),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeOverLarge),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            MenuItem(
                              iconImage: Images.userSvg,
                              label: getTranslated('my_profile', context)!,
                              onTap: () {
                                if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                  RouterHelper.getLoginRoute(action: RouteAction.push, fromPage: RouterHelper.moreScreen);
                                } else {
                                  context.push(RouterHelper.profileScreen1);
                                }
                              },
                            ),
                            const Divider(height: 1, indent: Dimensions.paddingSizeDefault, endIndent: Dimensions.paddingSizeDefault),
                            MenuItem(
                              iconImage: Images.notification,
                              label: getTranslated('notification', context)!,
                              trailing: _buildNotificationBadge(),
                              onTap: () => context.push(RouterHelper.notificationScreen),
                            ),
                            const Divider(height: 1, indent: Dimensions.paddingSizeDefault, endIndent: Dimensions.paddingSizeDefault),
                            MenuItem(
                              iconImage: Images.settings,
                              label: getTranslated('settings', context)!,
                              onTap: () => context.push(RouterHelper.settingsScreen),
                            ),
                            const Divider(height: 1, indent: Dimensions.paddingSizeDefault, endIndent: Dimensions.paddingSizeDefault),
                            MenuItem(
                              iconImage: Images.walletIcon,
                              label: getTranslated('payment', context) ?? 'Payment',
                              trailing: Consumer2<AuthController, WalletController>(
                                builder: (context, authController, walletController, _) {
                                  if (!authController.isLoggedIn()) return const SizedBox.shrink();
                                  final balance = walletController.walletTransactionModel?.totalWalletBalance ?? 0.0;
                                  return TrailingBadge(
                                    label: PriceConverter.convertPrice(context, balance),
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                    textColor: Theme.of(context).colorScheme.primary,
                                  );
                                },
                              ),
                              onTap: () {
                                if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                  RouterHelper.getLoginRoute(action: RouteAction.push, fromPage: RouterHelper.moreScreen);
                                } else {
                                  RouterHelper.getWalletRoute(action: RouteAction.push);
                                }
                              },
                            ),
                            const Divider(height: 1, indent: Dimensions.paddingSizeDefault, endIndent: Dimensions.paddingSizeDefault),
                            SettingsGroup(
                              title: getTranslated('shopping', context) ?? 'Shopping',
                              initiallyExpanded: false,
                              children: [
                                MenuItem(
                                  iconImage: Images.cartSvg,
                                  label: getTranslated('cart', context)!,
                                  onTap: () => RouterHelper.getCartScreenRoute(action: RouteAction.push),
                                ),
                                MenuItem(
                                  iconImage: Images.wishlistSvg,
                                  label: getTranslated('wishlist', context)!,
                                  onTap: () {
                                    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.auctionQueueListScreen),
                                      );
                                    } else {
                                      RouterHelper.getWishListRoute(action: RouteAction.push);
                                    }
                                  },
                                ),
                                MenuItem(
                                  iconImage: Images.offerSvg,
                                  label: getTranslated('offers', context)!,
                                  onTap: () => RouterHelper.getOfferProductListScreenRoute(action: RouteAction.push),
                                ),
                                MenuItem(
                                  iconImage: Images.couponsIcon,
                                  label: getTranslated('coupons', context)!,
                                  onTap: () {
                                    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                                      );
                                    } else {
                                      RouterHelper.getCouponListScreenRoute();
                                    }
                                  },
                                ),
                                MenuItem(
                                  iconImage: Images.compareIconSvg,
                                  label: getTranslated('compare_products', context)!,
                                  onTap: () {
                                    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                                      );
                                    } else {
                                      RouterHelper.getCompareProductScreenRoute();
                                    }
                                  },
                                ),
                                MenuItem(
                                  iconImage: Images.navCategoryIcon,
                                  label: getTranslated('category', context)!,
                                  onTap: () => context.push(RouterHelper.categoryScreen),
                                ),
                                if (authController.isLoggedIn())
                                  MenuItem(
                                    iconImage: Images.restockRequestSvg,
                                    label: getTranslated('restock_requests', context)!,
                                    onTap: () => RouterHelper.getRestockListRoute(action: RouteAction.push),
                                  ),
                                if (splashController.configModel?.blogUrl?.isNotEmpty ?? false)
                                  MenuItem(
                                    iconImage: Images.blogSvg,
                                    label: getTranslated('blog', context)!,
                                    onTap: () => RouterHelper.getBlogScreenRoute(
                                      action: RouteAction.push,
                                      url: splashController.configModel?.blogUrl ?? '',
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(height: 1, indent: Dimensions.paddingSizeDefault, endIndent: Dimensions.paddingSizeDefault),
                            SettingsGroup(
                              title: getTranslated('orders_and_wallet', context) ?? 'Orders & Wallet',
                              initiallyExpanded: false,
                              children: [
                                MenuItem(
                                  iconImage: Images.navBidIcon,
                                  label: getTranslated('order_history', context)!,
                                  onTap: () {
                                    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                                      );
                                    } else {
                                      RouterHelper.getOrderScreenRoute(action: RouteAction.push);
                                    }
                                  },
                                ),
                                MenuItem(
                                  iconImage: Images.newTrackOrderIcon,
                                  label: getTranslated('track_order', context)!,
                                  onTap: () => RouterHelper.getGuestTrackOrderRoute(action: RouteAction.push),
                                ),
                                MenuItem(
                                  iconImage: Images.walletIcon,
                                  label: getTranslated('wallet', context)!,
                                  trailing: Consumer2<AuthController, WalletController>(
                                    builder: (context, authController, walletController, _) {
                                      if (!authController.isLoggedIn()) return const SizedBox.shrink();
                                      final balance = walletController.walletTransactionModel?.totalWalletBalance ?? 0.0;
                                      return TrailingBadge(
                                        label: PriceConverter.convertPrice(context, balance),
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                        textColor: Theme.of(context).colorScheme.primary,
                                      );
                                    },
                                  ),
                                  onTap: () {
                                    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.auctionQueueListScreen),
                                      );
                                    } else {
                                      RouterHelper.getWalletRoute(action: RouteAction.push);
                                    }
                                  },
                                ),
                                MenuItem(
                                  iconImage: Images.loyaltyPointsIcon,
                                  label: getTranslated('loyalty_points', context)!,
                                  trailing: Consumer2<AuthController, ProfileController>(
                                    builder: (context, authController, profileController, _) {
                                      if (!authController.isLoggedIn()) return const SizedBox.shrink();
                                      final points = profileController.userInfoModel?.loyaltyPoint ?? 0;
                                      return TrailingBadge(
                                        label: '$points ${getTranslated('points', context)!}',
                                        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.35),
                                        textColor: Theme.of(context).colorScheme.tertiary,
                                      );
                                    },
                                  ),
                                  onTap: () {
                                    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.auctionQueueListScreen),
                                      );
                                    } else {
                                      RouterHelper.getLoyaltyPointScreenRoute(action: RouteAction.push);
                                    }
                                  },
                                ),
                                if (splashController.configModel?.refEarningStatus == '1')
                                  MenuItem(
                                    iconImage: Images.referEarnIcon,
                                    label: getTranslated('refer_and_earn', context)!,
                                    onTap: () {
                                      if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                                        );
                                      } else {
                                        RouterHelper.getReferAndEarnRoute(action: RouteAction.push);
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const Divider(height: 1, indent: Dimensions.paddingSizeDefault, endIndent: Dimensions.paddingSizeDefault),
                            SettingsGroup(
                              title: getTranslated('help_and_support', context)!,
                              initiallyExpanded: false,
                              children: [
                                MenuItem(
                                  iconImage: Images.supportTicketSvg,
                                  label: getTranslated('support_ticket', context)!,
                                  onTap: () => RouterHelper.getSupportTicketRoute(action: RouteAction.push),
                                ),
                                MenuItem(
                                  iconImage: Images.faqSvg,
                                  label: getTranslated('faq', context)!,
                                  onTap: () => RouterHelper.getFaqRoute(action: RouteAction.push),
                                ),
                                MenuItem(
                                  iconImage: Images.messageImage,
                                  label: getTranslated('inbox', context)!,
                                  onTap: () => context.push(RouterHelper.inboxScreen),
                                ),
                                MenuItem(
                                  iconImage: Images.contactUs,
                                  label: getTranslated('contact_us', context)!,
                                  onTap: () => context.push(RouterHelper.contactUsScreen),
                                ),
                                if (_getPageBySlug('about-us', splashController.defaultBusinessPages) != null)
                                  MenuItem(
                                    iconImage: Images.aboutUsSvg,
                                    label: getTranslated('about_us', context)!,
                                    onTap: () => RouterHelper.getHtmlViewRoute(
                                      page: _getPageBySlug('about-us', splashController.defaultBusinessPages)!,
                                    ),
                                  ),
                                if (splashController.businessPages != null && splashController.businessPages!.isNotEmpty)
                                  ...splashController.businessPages!.map((page) => MenuItem(
                                    iconImage: Images.loyaltyPointsIcon,
                                    label: page.title ?? '',
                                    onTap: () => RouterHelper.getHtmlViewRoute(page: page),
                                  )),
                                if (_getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages) != null)
                                  MenuItem(
                                    iconImage: Images.tremsConditionSvg,
                                    label: getTranslated('terms_condition', context)!,
                                    onTap: () => RouterHelper.getHtmlViewRoute(
                                      page: _getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages)!,
                                    ),
                                  ),
                                if (_getPageBySlug('privacy-policy', splashController.defaultBusinessPages) != null)
                                  MenuItem(
                                    iconImage: Images.policySvg,
                                    label: getTranslated('privacy_policy', context)!,
                                    onTap: () => RouterHelper.getHtmlViewRoute(
                                      page: _getPageBySlug('privacy-policy', splashController.defaultBusinessPages)!,
                                    ),
                                  ),
                                if (_getPageBySlug('refund-policy', splashController.defaultBusinessPages) != null)
                                  MenuItem(
                                    iconImage: Images.policySvg,
                                    label: getTranslated('refund_policy', context)!,
                                    onTap: () => RouterHelper.getHtmlViewRoute(
                                      page: _getPageBySlug('refund-policy', splashController.defaultBusinessPages)!,
                                    ),
                                  ),
                                if (_getPageBySlug('return-policy', splashController.defaultBusinessPages) != null)
                                  MenuItem(
                                    iconImage: Images.policySvg,
                                    label: getTranslated('return_policy', context)!,
                                    onTap: () => RouterHelper.getHtmlViewRoute(
                                      page: _getPageBySlug('return-policy', splashController.defaultBusinessPages)!,
                                    ),
                                  ),
                                if (_getPageBySlug('cancellation-policy', splashController.defaultBusinessPages) != null)
                                  MenuItem(
                                    iconImage: Images.policySvg,
                                    label: getTranslated('cancellation_policy', context)!,
                                    onTap: () => RouterHelper.getHtmlViewRoute(
                                      page: _getPageBySlug('cancellation-policy', splashController.defaultBusinessPages)!,
                                    ),
                                  ),
                                if (_getPageBySlug('shipping-policy', splashController.defaultBusinessPages) != null)
                                  MenuItem(
                                    iconImage: Images.policySvg,
                                    label: getTranslated('shipping_policy', context)!,
                                    onTap: () => RouterHelper.getHtmlViewRoute(
                                      page: _getPageBySlug('shipping-policy', splashController.defaultBusinessPages)!,
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(height: 1, indent: Dimensions.paddingSizeDefault, endIndent: Dimensions.paddingSizeDefault),
                            MenuItem(
                              iconImage: Images.logout,
                              label: getTranslated('sign_out', context) ?? 'Sign Out',
                              onTap: () {
                                if (!_authController.isLoggedIn()) {
                                  RouterHelper.getLoginRoute(action: RouteAction.push, fromPage: RouterHelper.moreScreen);
                                } else {
                                  LogoutCustomBottomSheetWidget.show(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    if ((splashController.configModel?.isAuctionFeatureEnabled == true) ||
                        (Provider.of<ProfileController>(context, listen: false).userInfoModel?.showAuctionMenuForUser == true)) ...[
                    SectionHeader(title: getTranslated('bidding_activity', context)!),

                    MenuItem(
                      iconImage: Images.navBidIcon,
                      label: getTranslated('my_bids', context)!,
                      badgeCount: isLoggedIn ? summaryModel?.totalMyBids : null,
                      onTap: () {
                        if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                          );
                        } else {
                          RouterHelper.getMyBidsScreen(action: RouteAction.push);
                        }
                      },
                    ),

                    MenuItem(
                      iconImage: Images.saveIcon,
                      label: getTranslated('saved_auction', context)!,
                      badgeCount: isLoggedIn ? summaryModel?.totalMySavedAuctions : null,
                      onTap: () {
                        if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                          );
                        } else {
                          RouterHelper.getSavedAuctionListScreen(action: RouteAction.push);
                        }
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    SectionHeader(title: getTranslated('my_auctions', context)!),

                    if ((splashController.configModel?.isAuctionFeatureEnabled == true) && (splashController.configModel?.isActiveAuctionForCustomer == true))
                    MenuItem(
                      iconImage: Images.navAuctionIcon,
                      label: getTranslated('create_auction', context)!,
                      onTap: () {
                        if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                          );
                        } else {
                          RouterHelper.getAddEditAuctionProductRoute(action: RouteAction.push, fromDetails: false);
                        }
                      },
                    ),

                    MenuItem(
                      iconImage: Images.allAuctionIcon,
                      label: getTranslated('all_auctions', context)!,
                      badgeCount: isLoggedIn ? summaryModel?.totalMyAuctions : null,
                      onTap: () {
                        if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                          );
                        } else {
                          RouterHelper.getUserCreatedAuctionListScreenRoute(action: RouteAction.push);
                        }
                      },
                    ),

                    MenuItem(
                      iconImage: Images.navActivityIcon,
                      label: getTranslated('auction_request_list', context)!,
                      badgeCount: isLoggedIn ? summaryModel?.totalMyAuctionPending : null,
                      onTap: () {
                        if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                          );
                        } else {
                          RouterHelper.getAuctionQueueListRoute(action: RouteAction.push);
                        }
                      },
                    ),

                    MenuItem(
                      iconImage: Images.auctionReportIcon,
                      label: getTranslated('auction_sales_report', context)!,
                      onTap: () {
                        if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                          );
                        } else {
                          RouterHelper.getAuctionSalesReportRoute(action: RouteAction.push);
                        }
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    MenuItem(
                      iconImage: Images.transactionSvg,
                      label: getTranslated('auction_transaction_history', context)!,
                      onTap: () {
                        if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => NotLoggedInBottomSheetWidget(fromPage: RouterHelper.moreScreen, onLoginSuccess: _onLoginSuccess),
                          );
                        } else {
                          RouterHelper.getAuctionTransactionListScreenRoute(action: RouteAction.push);
                        }
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],

                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
        ),
      ),
    ));
  }
}

class RailBadge extends StatelessWidget {
  final String count;
  const RailBadge(this.count, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Text(count,
        style: titilliumBold.copyWith(fontSize: 8, color: Colors.white),
      ),
    );
  }
}


class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor: Theme.of(context).hintColor,
        title: Text(title,
          style: titilliumBold.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        children: children,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        top: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeExtraExtraSmall,
      ),
      child: Text(title,
        style: titilliumRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

class QuickActionItem extends StatelessWidget {
  final String iconImage;
  final String label;
  final VoidCallback onTap;

  const QuickActionItem({
    super.key,
    required this.iconImage,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomAssetImageWidget(
              iconImage,
              width: Dimensions.iconSizeLarge,
              height: Dimensions.iconSizeLarge,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String iconImage;
  final String label;
  final int? badgeCount;
  final Widget? trailing;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.iconImage,
    required this.label,
    this.badgeCount,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        child: Row(
          children: [
            CustomAssetImageWidget(
              iconImage,
              width: Dimensions.iconSizeDefault,
              height: Dimensions.iconSizeDefault,
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Text(
                label,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (badgeCount != null)
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else if (trailing != null)
              trailing!,
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Icon(
              Icons.chevron_right_rounded,
              size: Dimensions.iconSizeDefault,
              color: Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}

class TrailingBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const TrailingBadge({super.key, required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Text(label,
        style: titilliumBold.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: textColor,
        ),
      ),
    );
  }
}