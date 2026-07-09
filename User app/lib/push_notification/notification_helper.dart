import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/demo_reset_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/restock/controllers/restock_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/restock/widgets/restock_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/creator/creator_auction_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/participation_auction_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/screens/creator_auction_details_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/screens/participation_auction_details_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/models/notification_body.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const customerAuctionTypes = {
  'auction_went_live',
  'auction_participation_payment_verified',
  'auction_outbid',
  'auction_won',
  'auction_delivery_ready',
  'auction_delivery_on_the_way',
  'auction_delivered',
  'auction_claim_payment_verified',
  'auction_commission_payment_verified',
  'auction_claim_expired',
};

const sellerAuctionTypes = {
  'auction_approved',
  'auction_denied',
  'auction_new_participation',
  'auction_new_bid',
  'auction_expired_result',
  'auction_item_claimed',
  'auction_claim_payment_verified_owner',
  'auction_withdrawal_approved',
  'auction_withdrawal_rejected',
};

class NotificationHelper {


  // {is_read: 0, image: , body: new-messages.demo_data_is_being_reset_to_default., type: demo_reset, title: Demo reset alert, order_id: }

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    flutterLocalNotificationsPlugin.initialize(settings: initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse load) async {
      try{
        log("tyyuuyypee88=11=>$load");
        log("==Payload=11=>${load.payload}");
        NotificationBody payload;

        if(load.payload!.isNotEmpty) {
          payload = NotificationBody.fromJson(jsonDecode(load.payload!));
          log("-----------tyyuuyypee88==>${payload.type}");
          log("=============Payload==>${load.payload}");
          if(payload.type == 'order') {
            RouterHelper.getOrderDetailsScreenRoute(
              action: RouteAction.pushReplacement,
              orderId: payload.orderId!,
              isNotification: true
            );
          } else if(payload.type == 'wallet') {
            RouterHelper.getWalletRoute(action: RouteAction.pushReplacement, isBackButtonExist: true);
          } else if(payload.type == 'chatting') {
            RouterHelper.getInboxScreenRoute(
              action: RouteAction.pushReplacement,
              isBackButtonExist: true,
              initIndex: payload.messageKey == 'message_from_delivery_man' ? 0 : 1,
              fromNotification: true,
            );
          } else if(payload.type == 'product_restock_update') {
            RouterHelper.getProductDetailsRoute(action: RouteAction.pushReplacement, productId: int.parse(payload.productId!), slug: payload.slug, isNotification: true);
          } else if(payload.type == 'referral_code_used'){

          } else if(customerAuctionTypes.contains(payload.type)) {
            if (payload.auctionSlug != null) {
              RouterHelper.getParticipationAuctionDetailsRoute(slug: payload.auctionSlug!, isNotification: true, action: RouteAction.pushReplacement);
            } else {
              RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
            }
          } else if(sellerAuctionTypes.contains(payload.type)) {
            if (payload.auctionSlug != null) {
              RouterHelper.getCreatorAuctionDetailsRoute(slug: payload.auctionSlug!, isNotification: true, action: RouteAction.pushReplacement);
            } else {
              RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
            }
          } else{
            RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
          }
        }
      }catch (_) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("-----------onMessageOutFromKDebugMode: ${message.toMap()}");
      if (kDebugMode) {
        log("-----------onMessage: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
        log("---------onMessage type: ${message.data['type']}/${message.data}");
        log("---------onMessage auction_id ${message.data['auction_id']}");
        log("---------onMessage auction_slug ${message.data['auction_slug']}");
        if(message.data['type'] == "block") {
          Provider.of<AuthController>(Get.context!,listen: false).clearSharedData();
          Provider.of<AddressController>(Get.context!, listen: false).getAddressList();
          RouterHelper.getLoginRoute(action: RouteAction.pushNamedAndRemoveUntil);
        }
      }

      if(message.data['type'] == 'referral_code_used'){
        await Provider.of<WalletController>(Get.context!, listen: false).getTransactionList(1);
      }

      if(message.data['type'] == 'maintenance_mode') {
        final SplashController splashProvider = Provider.of<SplashController>(Get.context!,listen: false);
        await splashProvider.initConfig(Get.context!, null, null);

        ConfigModel? config = Provider.of<SplashController>(Get.context!,listen: false).configModel;

        bool isMaintenanceRoute = Provider.of<SplashController>(Get.context!,listen: false).isMaintenanceModeScreen();

        if(config?.maintenanceModeData?.maintenanceStatus == 1 && (config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1)) {
          RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
        }else if (config?.maintenanceModeData?.maintenanceStatus == 0 && isMaintenanceRoute) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
        }
      }

      if(message.data['type'] == 'auction_outbid') {
        final String currentUserId = Provider.of<ProfileController>(Get.context!, listen: false).userID;
        final String? excludedId = message.data['excluded_user_id'];
        if (excludedId != null && excludedId.isNotEmpty && excludedId == currentUserId) {
          return;
        }

        final int? notifAuctionId = int.tryParse(message.data['auction_id']?.toString() ?? '');
        final String? notifAuctionSlug = message.data['auction_slug']?.toString();
        if (notifAuctionSlug != null &&
            ParticipationAuctionDetailsScreen.activeSlug == notifAuctionSlug) {
          if (notifAuctionId != null) {
            Provider.of<ParticipationAuctionDetailsController>(Get.context!, listen: false).getAuctionBidList(productId: notifAuctionId);
          }
          Provider.of<ParticipationAuctionDetailsController>(Get.context!, listen: false).getAuctionProductOverview(Get.context!, slug: notifAuctionSlug, silent: true);
          return;
        }
      }

      if(message.data['type'] == 'auction_new_bid') {
        final int? notifAuctionId = int.tryParse(message.data['auction_id']?.toString() ?? '');
        final String? notifAuctionSlug = message.data['auction_slug']?.toString();
        if (notifAuctionId != null && notifAuctionSlug != null && CreatorAuctionDetailsScreen.activeSlug == notifAuctionSlug) {
          Provider.of<CreatorAuctionDetailsController>(Get.context!, listen: false).getAuctionBidList(productId: notifAuctionId);
          return;
        }
      }

      if(message.data['type'] != 'maintenance_mode' || message.data['type'] != 'product_restock_update') {
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
      }

      if(message.data['type'] == 'product_restock_update' && !Provider.of<RestockController>(Get.context!, listen: false).isBottomSheetOpen){
        NotificationBody notificationBody = convertNotification(message.data);
        Provider.of<RestockController>(Get.context!, listen: false).setBottomSheetOpen(true);
        final result = await showModalBottomSheet(context: Get.context!, isScrollControlled: true,
          backgroundColor: Theme.of(Get.context!).primaryColor.withValues(alpha:0),
          builder: (con) => RestockSheetWidget(notificationBody: notificationBody),
        );

        if (result == null) {
          Provider.of<RestockController>(Get.context!, listen: false).setBottomSheetOpen(false);
        } else {
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print("onOpenApp: ${message.notification!.title}/${message.data}/${message.notification!.titleLocKey}");
      }
      if(message.data['type'] == 'demo_reset') {
        showDialog(context: Get.context!, builder: (context) => const Dialog(
          backgroundColor: Colors.transparent,
          child: DemoResetDialogWidget()));
      }
      try{
        if(message.data.isNotEmpty) {
          NotificationBody notificationBody = convertNotification(message.data);
          if(notificationBody.type == 'order') {
            RouterHelper.getOrderDetailsScreenRoute(
              action: RouteAction.pushReplacement,
              orderId: notificationBody.orderId!,
              isNotification: true
            );

          } else if(notificationBody.type == 'wallet') {
            RouterHelper.getWalletRoute(action: RouteAction.pushReplacement, isBackButtonExist: true);
          } else if(notificationBody.type == 'notification') {
            RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
          } else if(notificationBody.type == 'chatting') {
            RouterHelper.getInboxScreenRoute(
              action: RouteAction.pushReplacement,
              isBackButtonExist: true,
              fromNotification: true,
              initIndex: notificationBody.messageKey == 'message_from_delivery_man' ? 0 : 1,
            );
          } else if(notificationBody.type == 'product_restock_update') {
            RouterHelper.getProductDetailsRoute(action: RouteAction.pushReplacement, productId: int.parse(notificationBody.productId!), slug: notificationBody.slug, isNotification: true);
          } else if(customerAuctionTypes.contains(notificationBody.type)) {
            if (notificationBody.auctionSlug != null) {
              RouterHelper.getParticipationAuctionDetailsRoute(slug: notificationBody.auctionSlug!, action: RouteAction.pushReplacement);
            } else {
              RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
            }
          } else if(sellerAuctionTypes.contains(notificationBody.type)) {
            if (notificationBody.auctionSlug != null) {
              RouterHelper.getCreatorAuctionDetailsRoute(slug: notificationBody.auctionSlug!, action: RouteAction.pushReplacement);
            } else {
              RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
            }
          } else {
            RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
          }
        }
      }catch (_) {}

      if(message.data['type'] == 'maintenance_mode') {
        final SplashController splashProvider = Provider.of<SplashController>(Get.context!,listen: false);
        await splashProvider.initConfig(Get.context!, null, null);

        ConfigModel? config = Provider.of<SplashController>(Get.context!,listen: false).configModel;

        bool isMaintenanceRoute = Provider.of<SplashController>(Get.context!,listen: false).isMaintenanceModeScreen();

        if(config?.maintenanceModeData?.maintenanceStatus == 1 && (config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1)) {
          RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
        }else if (config?.maintenanceModeData?.maintenanceStatus == 0 && isMaintenanceRoute) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
        }
      }

    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
    if(!Platform.isIOS) {
      String? title;
      String? body;
      String? orderID;
      String? image;
      NotificationBody notificationBody = convertNotification(message.data);
      if(data) {
        title = message.data['title'];
        body = message.data['body'];
        orderID = message.data['order_id'];
        image = (message.data['image'] != null && message.data['image'].isNotEmpty)
            ? message.data['image'].startsWith('http') ? message.data['image']
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;
      }else {
        title = message.notification?.title;
        body = message.notification?.body;
        orderID = message.notification?.titleLocKey;
        if(Platform.isAndroid) {
          image = (message.notification?.android?.imageUrl != null && message.notification!.android!.imageUrl!.isNotEmpty)
              ? message.notification!.android!.imageUrl!.startsWith('http') ? message.notification!.android!.imageUrl
              : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification?.android?.imageUrl}' : null;
        }else if(Platform.isIOS) {
          image = (message.notification?.apple?.imageUrl != null && message.notification!.apple!.imageUrl!.isNotEmpty)
              ? message.notification!.apple!.imageUrl!.startsWith('http') ? message.notification?.apple?.imageUrl
              : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification!.apple!.imageUrl}' : null;
        }
      }

      if(image != null && image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(title, body, orderID, notificationBody, image, fln);
        }catch(e) {
          await showBigTextNotification(title, body!, orderID, notificationBody, fln);
        }
      }else {
        await showBigTextNotification(title, body!, orderID, notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body, String orderID, NotificationBody? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6valley', '6valley', playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: 0, title: title, body:  body, notificationDetails: platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigTextNotification(String? title, String body, String? orderID, NotificationBody? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6valley', '6valley', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: 0, title: title, body:  body, notificationDetails: platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, String? orderID, NotificationBody? notificationBody, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6valley', '6valley',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: 0, title : title, body: body, notificationDetails: platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static Future<void> subscribeToAuctionTopics(int auctionId) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('auction_went_live_$auctionId');
      await FirebaseMessaging.instance.subscribeToTopic('auction_outbid_$auctionId');
      log('FCM subscribed to auction topics for auctionId=$auctionId');
    } catch (e) {
      log('FCM topic subscription failed for auctionId=$auctionId: $e');
    }
  }

  static Future<void> unsubscribeFromAuctionTopics(int auctionId) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('auction_went_live_$auctionId');
    await FirebaseMessaging.instance.unsubscribeFromTopic('auction_outbid_$auctionId');
  }

  static NotificationBody convertNotification(Map<String, dynamic> data){
    if(data['type'] == 'notification') {
      return NotificationBody(type: 'notification');
    }else if(data['type'] == 'order') {
      return NotificationBody(type: 'order', orderId: int.parse(data['order_id']));
    }else if(data['type'] == 'wallet') {
      return NotificationBody(type: 'wallet');
    }else if(data['type'] == 'block') {
      return NotificationBody(type: 'block');
    }else if(data['type'] == 'product_restock_update') {
      return NotificationBody(type: 'product_restock_update', title: data['title'], image: data['image'], productId: data['product_id'].toString(), slug: data['slug'], status: data['status']);
    } else if(data['type'] == 'referral_code_used') {
      return NotificationBody(type: 'referral_code_used', title: data['title'], messageKey: data['body'], image: data['image'], productId: data['product_id'].toString(), slug: data['slug'], status: data['status']);
    } else if(customerAuctionTypes.contains(data['type']) || sellerAuctionTypes.contains(data['type'])) {
      return NotificationBody(
        type: data['type'],
        auctionId: data['auction_id'] != null ? int.tryParse(data['auction_id'].toString()) : null,
        auctionSlug: data['auction_slug'],
      );
    } else {
      return NotificationBody(type: 'chatting', messageKey: data['message_key']);
    }
  }

}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("onBackground: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
  }
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}