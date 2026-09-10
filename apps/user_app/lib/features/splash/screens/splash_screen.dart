import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/bouncy_widget.dart';
import 'package:user_app/features/splash/controllers/splash_controller.dart';
import 'package:user_app/features/splash/domain/models/config_model.dart';
import 'package:user_app/helper/network_info.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/main.dart';
import 'package:user_app/push_notification/models/notification_body.dart';
import 'package:user_app/push_notification/notification_helper.dart';
import 'package:user_app/features/auth/controllers/auth_controller.dart';
import 'package:user_app/theme/controllers/theme_controller.dart';
import 'package:user_app/utill/app_constants.dart';
import 'package:user_app/utill/brand_colors.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/utill/images.dart';
import 'package:user_app/common/basewidget/no_internet_screen_widget.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  // late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    // bool firstTime = true;
    // _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   if(!firstTime) {
    //     bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
    //     isNotConnected ? const SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       backgroundColor: isNotConnected ? Colors.red : Colors.green,
    //       duration: Duration(seconds: isNotConnected ? 6000 : 3),
    //       content: Text(isNotConnected ? getTranslated('no_connection', context)! : getTranslated('connected', context)!,
    //         textAlign: TextAlign.center)));
    //     if(!isNotConnected) {
    //       _route();
    //     }
    //   }
    //   firstTime = false;
    // });

    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await Future.delayed(const Duration(milliseconds: 500));
    NotificationBody? initialBody;
    try {
      final RemoteMessage? msg = await FirebaseMessaging.instance.getInitialMessage();
      if (msg != null) initialBody = NotificationHelper.convertNotification(msg.data);
    } catch (_) {}
    _route(initialBody: initialBody);
  }

  @override
  void dispose() {
    super.dispose();
    // _onConnectivityChanged.cancel();
  }

  void _route({NotificationBody? initialBody}) {
    NetworkInfo.checkConnectivity(context);
    Provider.of<SplashController>(context, listen: false).initConfig(context, (ConfigModel? configModel) {
        String? minimumVersion = "0";
        UserAppVersionControl? appVersion = Provider.of<SplashController>(Get.context!, listen: false).configModel?.userAppVersionControl;
        if(Platform.isAndroid) {
          minimumVersion =  appVersion?.forAndroid?.version ?? '0';
        } else if(Platform.isIOS) {
          minimumVersion = appVersion?.forIos?.version ?? '0';
        }
        Provider.of<SplashController>(Get.context!, listen: false).initSharedPrefData();
        // Timer(const Duration(seconds: 2), () {
          final config = Provider.of<SplashController>(Get.context!, listen: false).configModel;

          Future.delayed(const Duration(milliseconds: 0)).then((_) {
            if(compareVersions(minimumVersion!, AppConstants.appVersion) == 1) {
              RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
            } else if(
            config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1
                && !Provider.of<SplashController>(Get.context!, listen: false).isConfigCall) {
              RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
            } else if(Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()) {
              Provider.of<AuthController>(Get.context!, listen: false).updateToken(Get.context!);
              final effectiveBody = widget.body ?? initialBody;
              if(effectiveBody != null){
                if (effectiveBody.type == 'order') {
                  RouterHelper.getOrderDetailsScreenRoute(
                    action: RouteAction.pushReplacement,
                    orderId: effectiveBody.orderId!,
                  );
                } else if(effectiveBody.type == 'notification') {
                  RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement);
                } else if(effectiveBody.type == 'wallet') {
                  RouterHelper.getWalletRoute(action: RouteAction.pushReplacement, isBackButtonExist: true);
                } else if(effectiveBody.type == 'chatting') {
                  RouterHelper.getInboxScreenRoute(
                    action: RouteAction.pushReplacement,
                    isBackButtonExist: true,
                    fromNotification: true,
                    initIndex: effectiveBody.messageKey == 'message_from_delivery_man' ? 0 : 1,
                  );
                } else if(effectiveBody.type == 'product_restock_update') {
                  RouterHelper.getProductDetailsRoute(action: RouteAction.pushReplacement, productId: int.parse(effectiveBody.productId!), slug: effectiveBody.slug, isNotification: true);
                } else if(customerAuctionTypes.contains(effectiveBody.type)) {
                  if (effectiveBody.auctionSlug != null) {
                    RouterHelper.getParticipationAuctionDetailsRoute(slug: effectiveBody.auctionSlug!, isNotification: true, action: RouteAction.pushReplacement);
                  } else {
                    RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
                  }
                } else if(sellerAuctionTypes.contains(effectiveBody.type)) {
                  if (effectiveBody.auctionSlug != null) {
                    RouterHelper.getCreatorAuctionDetailsRoute(slug: effectiveBody.auctionSlug!, isNotification: true, action: RouteAction.pushReplacement);
                  } else {
                    RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
                  }
                } else {
                  RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
                }
              }else{
                // Navigator.of(Get.context!).pushReplacement(
                //   PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                //     transitionDuration: Duration.zero, // Removes transition duration
                //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
                //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                //   ),
                // );

                RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
              }
            }

            else if(Provider.of<SplashController>(Get.context!, listen: false).showIntro()!){
              RouterHelper.getOnboardingRoute(
                action: RouteAction.pushReplacement,
                indicatorColor: Provider.of<ThemeController>(Get.context!, listen: false).darkTheme ?
                  Theme.of(Get.context!).colorScheme.onTertiary : Theme.of(Get.context!).hintColor,
                selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
              );
            }
            else{
              if(Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != null &&
                  Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != '1') {
                // Navigator.of(Get.context!).pushReplacement(
                //   PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                //     transitionDuration: Duration.zero, // Removes transition duration
                //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
                //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                //   ),
                // );

                RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);


              }else{
                Provider.of<AuthController>(Get.context!, listen: false).getGuestIdUrl();
                RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);

                // Navigator.of(Get.context!).pushReplacement(
                //   PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                //     transitionDuration: Duration.zero, // Removes transition duration
                //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
                //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                //   ),
                // );

              }
            }
          });
       //  });
      },


      (ConfigModel? configModel) {
        String? minimumVersion = "0";
        UserAppVersionControl? appVersion = Provider.of<SplashController>(Get.context!, listen: false).configModel?.userAppVersionControl;
        if(Platform.isAndroid) {
          minimumVersion =  appVersion?.forAndroid?.version ?? '0';
        } else if(Platform.isIOS) {
          minimumVersion = appVersion?.forIos?.version ?? '0';
        }
        Provider.of<SplashController>(Get.context!, listen: false).initSharedPrefData();
        // Timer(const Duration(seconds: 1), () {
          final config = Provider.of<SplashController>(Get.context!, listen: false).configModel;
          if(compareVersions(minimumVersion, AppConstants.appVersion) == 1) {
            RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
          } else if(
            config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1
            && !config!.localMaintenanceMode!
          ) {
            RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
          } else if(Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn() && !configModel!.hasLocaldb!) {
            Provider.of<AuthController>(Get.context!, listen: false).updateToken(Get.context!);
            final effectiveBody = widget.body ?? initialBody;
            if(effectiveBody != null) {
              if (effectiveBody.type == 'order') {
                RouterHelper.getOrderDetailsScreenRoute(
                  action: RouteAction.pushReplacement,
                  orderId: effectiveBody.orderId!,
                );
              } else if(effectiveBody.type == 'notification') {
                RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement);
              } else if(effectiveBody.type == 'wallet') {
                RouterHelper.getWalletRoute(action: RouteAction.pushReplacement, isBackButtonExist: true);
              } else if(effectiveBody.type == 'chatting') {
                RouterHelper.getInboxScreenRoute(
                  action: RouteAction.push,
                  isBackButtonExist: true,
                  fromNotification: true,
                  initIndex: effectiveBody.messageKey == 'message_from_delivery_man' ? 0 : 1,
                );
              } else if(effectiveBody.type == 'product_restock_update') {
                RouterHelper.getProductDetailsRoute(action: RouteAction.push, productId: int.parse(effectiveBody.productId!), slug: effectiveBody.slug, isNotification: true);
              } else if(customerAuctionTypes.contains(effectiveBody.type)) {
                if (effectiveBody.auctionSlug != null) {
                  RouterHelper.getParticipationAuctionDetailsRoute(slug: effectiveBody.auctionSlug!, isNotification: true, action: RouteAction.pushReplacement);
                } else {
                  RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
                }
              } else if(sellerAuctionTypes.contains(effectiveBody.type)) {
                if (effectiveBody.auctionSlug != null) {
                  RouterHelper.getCreatorAuctionDetailsRoute(slug: effectiveBody.auctionSlug!, isNotification: true, action: RouteAction.pushReplacement);
                } else {
                  RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
                }
              } else {
                RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
              }
            }else{
              RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
            }
          }

          else if(Provider.of<SplashController>(Get.context!, listen: false).showIntro()! &&  !configModel!.hasLocaldb!){
            RouterHelper.getOnboardingRoute(
              action: RouteAction.pushReplacement,
              indicatorColor: Provider.of<ThemeController>(Get.context!, listen: false).darkTheme ?
                Theme.of(Get.context!).colorScheme.onTertiary : Theme.of(Get.context!).hintColor,
              selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
            );
          }
          else if(!configModel!.hasLocaldb! || (configModel.hasLocaldb! && configModel.localMaintenanceMode! && !(config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1))){
            if(Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != null &&
                Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != '1'){
              RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
            }else{
              Provider.of<AuthController>(Get.context!, listen: false).getGuestIdUrl();
              RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
            }
          }
        // });
      }


    ).then((bool isSuccess) {
      if(isSuccess) {

      }
    });
  }


  int compareVersions(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');

    int maxLength = v1Components.length > v2Components.length
        ? v1Components.length
        : v2Components.length;

    for (int i = 0; i < maxLength; i++) {
      int v1Part = i < v1Components.length ? int.tryParse(v1Components[i]) ?? 0 : 0;
      int v2Part = i < v2Components.length ? int.tryParse(v2Components[i]) ?? 0 : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Provider.of<SplashController>(context).hasConnection ?
      SplashWidget() : const NoInternetOrDataScreenWidget(isNoInternet: true, child: SplashScreen()),
    );
  }
}

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Light rather than burgundy so the logo wordmark can keep its original
    // brown/red. On burgundy those inks measured 1.5:1 and 2.0:1 contrast; on
    // this sand they are 12.3:1 and 3.5:1 — the darkest tone that still keeps
    // the red above the 3:1 large-text floor.
    return ColoredBox(
      color: BrandColors.sand,
      child: Column(mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Row(children: []),
        // Brand mark, no badge needed now the background is light.
        BouncyWidget(
          duration: const Duration(milliseconds: 2000), lift: 50, ratio: 0.5, pause: 0.25,
          child: SizedBox(width: 190, child: Image.asset(Images.splashLogo))
        ),
        // Supplied transparent-background wordmark, used in its original
        // brown/red exactly as designed — no recolouring or keying.
        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
          child: SizedBox(width: 215, child: Image.asset(Images.splashWordmark)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: Text(AppConstants.slogan,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: BrandColors.burgundy))
        )
      ]),
    );
  }
}
