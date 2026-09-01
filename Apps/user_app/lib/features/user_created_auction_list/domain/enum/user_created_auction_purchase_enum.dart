// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
enum UserCreatedAuctionPurchaseEnum {
  upcoming,
  live,
  readyToClaim,
  purchaseComplete,
  readyToDelivery,
  onTheWay,
  delivered,
  unsold,
  canceled;

  static UserCreatedAuctionPurchaseEnum fromApi(String? status, String? deliveryStatus, {bool isRelaunched = false}) {
    switch (status) {
      case 'upcoming':
        return UserCreatedAuctionPurchaseEnum.upcoming;
      case 'live':
        return UserCreatedAuctionPurchaseEnum.live;
      case 'ready_to_claim':
        return UserCreatedAuctionPurchaseEnum.readyToClaim;
      case 'unsold':
        return UserCreatedAuctionPurchaseEnum.unsold;
      case 'canceled':
        return UserCreatedAuctionPurchaseEnum.canceled;
      default:
        switch (deliveryStatus) {
          case 'ready_to_delivery':
            return UserCreatedAuctionPurchaseEnum.readyToDelivery;
          case 'on_the_way':
            return UserCreatedAuctionPurchaseEnum.onTheWay;
          case 'delivered':
            return UserCreatedAuctionPurchaseEnum.delivered;
          default:
            return UserCreatedAuctionPurchaseEnum.purchaseComplete;
        }
    }
  }
}
