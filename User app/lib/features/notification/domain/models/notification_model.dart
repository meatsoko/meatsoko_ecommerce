import 'package:flutter_sixvalley_ecommerce/data/model/image_full_url.dart';

class NotificationItemModel {
  int? totalSize;
  int? limit;
  int? offset;
  int? newNotificationItem;
  List<NotificationItem>? notification;

  NotificationItemModel(
      {this.totalSize,
        this.limit,
        this.offset,
        this.newNotificationItem,
        this.notification});

  NotificationItemModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    newNotificationItem = json['new_notification'];
    if (json['notification'] != null) {
      notification = <NotificationItem>[];
      json['notification'].forEach((v) {
        notification!.add(NotificationItem.fromJson(v));
      });
    }
  }
}

class NotificationItem {
  int? id;
  String? sentBy;
  String? sentTo;
  String? title;
  String? description;
  int? notificationCount;
  String? image;
  ImageFullUrl? imageFullUrl;
  int? status;
  String? createdAt;
  String? updatedAt;
  NotificationSeenBy? seen;


  NotificationItem(
      {this.id,
        this.sentBy,
        this.sentTo,
        this.title,
        this.description,
        this.notificationCount,
        this.image,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.seen,
        this.imageFullUrl
      });

  NotificationItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sentBy = json['sent_by'];
    sentTo = json['sent_to'];
    title = json['title'];
    description = json['description'];
    notificationCount = int.parse(json['notification_count'].toString());
    image = json['image'];
    imageFullUrl = json['image_full_url'] != null
      ? ImageFullUrl.fromJson(json['image_full_url'])
      : null;
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    seen = json['notification_seen_by'] != null ? NotificationSeenBy.fromJson(json['notification_seen_by']) : null;

  }
}

class NotificationSeenBy {
  int? id;
  int? userId;
  int? notificationId;
  String? createdAt;


  NotificationSeenBy(
      {this.id,
        this.userId,
        this.notificationId,
        this.createdAt,
        });

  NotificationSeenBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = int.parse(json['user_id'].toString());
    notificationId = int.parse(json['notification_id'].toString());
    createdAt = json['created_at'];
  }
}

class AuctionNotificationListModel {
  int? totalSize;
  int? limit;
  int? offset;
  int? newAuctionNotification;
  List<AuctionNotificationItem>? notifications;

  AuctionNotificationListModel({this.totalSize, this.limit, this.offset, this.newAuctionNotification, this.notifications});

  AuctionNotificationListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    newAuctionNotification = json['new_notification'];
    if (json['notifications'] != null) {
      notifications = <AuctionNotificationItem>[];
      json['notifications'].forEach((v) {
        notifications!.add(AuctionNotificationItem.fromJson(v));
      });
    }
  }
}

int totalNewNotification(NotificationItemModel? general, AuctionNotificationListModel? auction, {bool isAuctionEnabled = true}) {
  return (general?.newNotificationItem ?? 0) + (isAuctionEnabled ? (auction?.newAuctionNotification ?? 0) : 0);
}

class AuctionNotificationItem {
  int? id;
  int? auctionProductId;
  String? slug;
  int? senderId;
  int? receiverId;
  String? senderType;
  String? receiverType;
  String? type;
  String? message;
  bool isRead;
  String? createdAt;
  String? updatedAt;
  String? auctionName;
  ImageFullUrl? imageFullUrl;

  AuctionNotificationItem({
    this.id,
    this.auctionProductId,
    this.slug,
    this.senderId,
    this.receiverId,
    this.senderType,
    this.receiverType,
    this.type,
    this.message,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
    this.auctionName,
    this.imageFullUrl,
  });

  String get typeLabel {
    if (type == null || type!.isEmpty) return '';
    return type!.split('_').map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
  }

  AuctionNotificationItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        auctionProductId = json['auction_product_id'],
        slug = json['slug'],
        senderId = json['sender_id'],
        receiverId = json['receiver_id'],
        senderType = json['sender_type'],
        receiverType = json['receiver_type'],
        type = json['type'],
        message = json['message'],
        isRead = json['is_read'] == true,
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        auctionName = json['auction_product_name'],
        imageFullUrl = json['auction_product_thumbnail_full_url'] != null ? ImageFullUrl(path: json['auction_product_thumbnail_full_url'] as String, status: 200) : null;
}