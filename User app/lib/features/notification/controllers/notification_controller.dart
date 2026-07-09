import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/domain/models/notification_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/domain/services/notification_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class NotificationController extends ChangeNotifier {
  final NotificationServiceInterface notificationServiceInterface;

  NotificationController({required this.notificationServiceInterface});

  NotificationItemModel? notificationModel;
  AuctionNotificationListModel? auctionNotificationModel;

  Future<void> getNotificationList(int offset) async {
    ApiResponseModel apiResponse = await notificationServiceInterface.getList(offset : offset);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      if(offset == 1){
        notificationModel = NotificationItemModel.fromJson(apiResponse.response?.data);
      }else{
        notificationModel?.notification?.addAll(NotificationItemModel.fromJson(apiResponse.response?.data).notification!);
        notificationModel?.offset = NotificationItemModel.fromJson(apiResponse.response?.data).offset!;
        notificationModel?.totalSize = NotificationItemModel.fromJson(apiResponse.response?.data).totalSize!;
      }
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
  }



  Future<void> seenNotification(int id) async {
    ApiResponseModel apiResponse = await notificationServiceInterface.seenNotification(id);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      getNotificationList(1);
    }
    notifyListeners();
  }

  Future<void> getAuctionNotificationList(int offset) async {
    ApiResponseModel apiResponse = await notificationServiceInterface.getAuctionList(offset: offset);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      if (offset == 1) {
        auctionNotificationModel = AuctionNotificationListModel.fromJson(apiResponse.response?.data);
      } else {
        final incoming = AuctionNotificationListModel.fromJson(apiResponse.response?.data);
        auctionNotificationModel?.notifications?.addAll(incoming.notifications ?? []);
        auctionNotificationModel?.offset = incoming.offset;
        auctionNotificationModel?.totalSize = incoming.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> markAuctionSeen({int? id}) async {
    ApiResponseModel apiResponse = await notificationServiceInterface.markAuctionSeen(id: id);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      getAuctionNotificationList(1);
    }
    notifyListeners();
  }
}
