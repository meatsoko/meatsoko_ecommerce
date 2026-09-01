import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:user_app/data/local/cache_response.dart';
import 'package:user_app/features/ai/controllers/auction_ai_controller.dart';
import 'package:user_app/features/auction/controllers/customer_auction_list_controller.dart';
import 'package:user_app/features/auction_category/controllers/auction_category_controller.dart';
import 'package:user_app/features/auction_checkout/controllers/auction_checkout_controller.dart';
import 'package:user_app/features/auction_details/controllers/creator/creator_auction_details_controller.dart';
import 'package:user_app/features/auction_details/controllers/participator/auction_participation_controller.dart';
import 'package:user_app/features/auction_details/controllers/participator/participation_auction_details_controller.dart';
import 'package:user_app/features/auction_home/controllers/auction_home_controller.dart';
import 'package:user_app/features/auction_list/controllers/auction_product_queue_controller.dart';
import 'package:user_app/features/auction_search/controllers/auction_search_controller.dart';
import 'package:user_app/features/auction_transaction/controller/auction_transaction_controller.dart';
import 'package:user_app/features/auth/controllers/facebook_login_controller.dart';
import 'package:user_app/features/auth/controllers/google_login_controller.dart';
import 'package:user_app/features/banner/controllers/banner_controller.dart';
import 'package:user_app/features/checkout/controllers/checkout_controller.dart';
import 'package:user_app/features/compare/controllers/compare_controller.dart';
import 'package:user_app/features/contact_us/controllers/contact_us_controller.dart';
import 'package:user_app/features/deal/controllers/featured_deal_controller.dart';
import 'package:user_app/features/deal/controllers/flash_deal_controller.dart';
import 'package:user_app/features/location/controllers/location_controller.dart';
import 'package:user_app/features/loyaltyPoint/controllers/loyalty_point_controller.dart';
import 'package:user_app/features/notification/controllers/notification_controller.dart';
import 'package:user_app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:user_app/features/order/controllers/order_controller.dart';
import 'package:user_app/features/order_details/controllers/order_details_controller.dart';
import 'package:user_app/features/product/controllers/product_controller.dart';
import 'package:user_app/features/product/controllers/seller_product_controller.dart';
import 'package:user_app/features/product_details/controllers/product_details_controller.dart';
import 'package:user_app/features/profile/controllers/profile_contrroller.dart';
import 'package:user_app/features/refund/controllers/refund_controller.dart';
import 'package:user_app/features/reorder/controllers/re_order_controller.dart';
import 'package:user_app/features/restock/controllers/restock_controller.dart';
import 'package:user_app/features/review/controllers/review_controller.dart';
import 'package:user_app/features/shipping/controllers/shipping_controller.dart';
import 'package:user_app/features/splash/controllers/splash_controller.dart';
import 'package:user_app/features/splash/screens/splash_screen.dart';
import 'package:user_app/features/support/controllers/support_ticket_controller.dart';
import 'package:user_app/features/user_created_auction_list/controllers/user_created_auction_list_controller.dart';
import 'package:user_app/features/vat_tax/controllers/vat_tax_controller.dart';
import 'package:user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:user_app/features/wishlist/controllers/wishlist_controller.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/controllers/localization_controller.dart';
import 'package:user_app/push_notification/models/notification_body.dart';
import 'package:user_app/features/address/controllers/address_controller.dart';
import 'package:user_app/features/auth/controllers/auth_controller.dart';
import 'package:user_app/features/brand/controllers/brand_controller.dart';
import 'package:user_app/features/cart/controllers/cart_controller.dart';
import 'package:user_app/features/category/controllers/category_controller.dart';
import 'package:user_app/features/chat/controllers/chat_controller.dart';
import 'package:user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:user_app/features/search_product/controllers/search_product_controller.dart';
import 'package:user_app/features/shop/controllers/shop_controller.dart';
import 'package:user_app/push_notification/notification_helper.dart';
import 'package:user_app/theme/controllers/theme_controller.dart';
import 'package:user_app/theme/dark_theme.dart';
import 'package:user_app/theme/light_theme.dart';
import 'package:user_app/utill/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'di_container.dart' as di;
import 'features/auction_dashboard_summary/controllers/auction_dashboard_summary_controller.dart';
import 'features/create_auction/controllers/add_auction_product_contoller.dart';
import 'features/create_auction/controllers/add_auction_product_media_controller.dart';
import 'features/splash/domain/models/config_model.dart';
import 'features/transaction/controllers/transaction_controller.dart';
import 'helper/custom_delegate.dart';
import 'localization/app_localization.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final database = AppDatabase();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }



  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await di.init();

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  String? path;
  NotificationBody? body;


  try {
    final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      body = NotificationHelper.convertNotification(remoteMessage.data);
    }
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    path =  await initDynamicLinks();
  } catch(_) {}

  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => di.sl<CategoryController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShopController>()),
      ChangeNotifierProvider(create: (context) => di.sl<FlashDealController>()),
      ChangeNotifierProvider(create: (context) => di.sl<FeaturedDealController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BrandController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BannerController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OnBoardingController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuthController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SearchProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CouponController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ChatController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderController>()),
      ChangeNotifierProvider(create: (context) => di.sl<NotificationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProfileController>()),
      ChangeNotifierProvider(create: (context) => di.sl<WishListController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SplashController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CartController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SupportTicketController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocalizationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ThemeController>()),
      ChangeNotifierProvider(create: (context) => di.sl<GoogleSignInController>()),
      ChangeNotifierProvider(create: (context) => di.sl<FacebookLoginController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddressController>()),
      ChangeNotifierProvider(create: (context) => di.sl<WalletController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CompareController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CheckoutController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LoyaltyPointController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ContactUsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShippingController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<RefundController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ReOrderController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ReviewController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SellerProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<RestockController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddAuctionProductMediaController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddAuctionProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionCategoryController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionHomeController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionSearchController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionProductQueueController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CreatorAuctionDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ParticipationAuctionDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CustomerAuctionListController>()),
      ChangeNotifierProvider(create: (context) => di.sl<VatTaxController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionAiController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionParticipationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionCheckoutController>()),
      ChangeNotifierProvider(create: (context) => di.sl<UserCreatedAuctionListController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionDashboardSummaryController>()),
      ChangeNotifierProvider(create: (context) => di.sl<TransactionController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuctionTransactionController>()),
    ],
    child: MyApp(body: body, route: path),
  ));
}

StreamSubscription<Uri?>? _sub;


Future<String?> initDynamicLinks() async {
  final appLinks = AppLinks();

  final uri = await appLinks.getInitialLink();
  if (uri != null) {
    return uri.path;
  }

  _sub = appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (navigatorKey.currentContext != null) {
          // navigatorKey.currentContext!.go(uri.path);
        }
      });
    }
  });

  return null;
}


class MyApp extends StatefulWidget {
  final NotificationBody? body;
  final String? route;
  const MyApp({
    super.key,
    required this.body,
    this.route
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    super.initState();
  }


  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }


  void _loadData() async {
    if(widget.route != null) {
      final AuthController authProvider = Provider.of<AuthController>(context, listen: false);

      if(Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
        await Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
      }

      if(mounted) {
        Provider.of<SplashController>(context, listen: false).initConfig(context, (_) {},
            (ConfigModel? configModel) async {
          if(configModel != null) {
            if (authProvider.isLoggedIn()) {
              await authProvider.updateToken(context);
            }
            // if(mounted && navigatorKey.currentContext != null) {
            //   navigatorKey.currentContext!.go(widget.route!);
            // }
          }
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }
    return Consumer<SplashController>(
      builder: (context, splashController, _) {
        return Consumer<ThemeController>(
          builder: (context, themeController, _) {
            if ((widget.route != null && splashController.configModel == null)) {
              return Theme(
                data : themeController.darkTheme ? dark : light(
                  primaryColor: Theme.of(context).primaryColor,
                  secondaryColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Directionality(
                textDirection: TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQueryData.fromView(View.of(context)),
                  child: SplashWidget()
                )
              ));
            } else {
              return MaterialApp.router(
              routerConfig: RouterHelper.goRoutes,
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: themeController.darkTheme ? dark : light(
                primaryColor: Theme.of(context).primaryColor,
                secondaryColor: Theme.of(context).colorScheme.secondary,
              ),
              locale: Provider.of<LocalizationController>(context).locale,
              localizationsDelegates: [
                AppLocalization.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FallbackLocalizationDelegate()
              ],
              builder:(context,child) {
                return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), child: SafeArea(top: false, child: child!));
              },
              supportedLocales: locals,
            );
            }
          }
        );
      }
    );
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}