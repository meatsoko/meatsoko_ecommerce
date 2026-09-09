// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/widgets.dart';
import 'package:user_app/localization/language_constrants.dart';

enum UserCreatedAuctionStatusEnum {
  all,
  upcoming,
  live,
  readyToClaim,
  purchaseComplete,
  readyToDelivery,
  onTheWay,
  delivered,
  unsold,
  canceled;

  String get key {
    switch (this) {
      case UserCreatedAuctionStatusEnum.all:
        return 'all';
      case UserCreatedAuctionStatusEnum.upcoming:
        return 'upcoming';
      case UserCreatedAuctionStatusEnum.live:
        return 'live';
      case UserCreatedAuctionStatusEnum.readyToClaim:
        return 'ready_to_claim';
      case UserCreatedAuctionStatusEnum.purchaseComplete:
        return 'purchase_complete';
      case UserCreatedAuctionStatusEnum.readyToDelivery:
        return 'ready_to_delivery';
      case UserCreatedAuctionStatusEnum.onTheWay:
        return 'on_the_way';
      case UserCreatedAuctionStatusEnum.delivered:
        return 'delivered';
      case UserCreatedAuctionStatusEnum.unsold:
        return 'unsold';
      case UserCreatedAuctionStatusEnum.canceled:
        return 'canceled';
    }
  }

  String label(BuildContext context) => getTranslated(key, context) ?? key;
}
