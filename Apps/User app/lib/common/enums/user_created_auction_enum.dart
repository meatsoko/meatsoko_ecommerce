enum UserCreatedAuctionEnum {
  // Approval states
  pending,
  rejected,

  // Auction states
  upcoming,
  live,
  readyToClaim,
  purchaseComplete,
  unsold,
  canceled,

  // Delivery states
  readyToDelivery,
  onTheWay,
  delivered;

  static UserCreatedAuctionEnum resolve({
    required String? approvalStatus,
    required String? auctionStatus,
    required String? deliveryStatus,
  }) {
    // Check approval status first
    switch (approvalStatus) {
      case 'pending':
        return UserCreatedAuctionEnum.pending;
      case 'rejected':
        return UserCreatedAuctionEnum.rejected;
      case 'approved':
        break; // proceed to auction status
      default:
        return UserCreatedAuctionEnum.pending;
    }

    // Check auction status
    switch (auctionStatus) {
      case 'upcoming':
        return UserCreatedAuctionEnum.upcoming;
      case 'live':
        return UserCreatedAuctionEnum.live;
      case 'ready_to_claim':
        return UserCreatedAuctionEnum.readyToClaim;
      case 'unsold':
        return UserCreatedAuctionEnum.unsold;
      case 'canceled':
        return UserCreatedAuctionEnum.canceled;
      default:
        if (deliveryStatus != null) {
          switch (deliveryStatus) {
            case 'ready_to_delivery':
              return UserCreatedAuctionEnum.readyToDelivery;
            case 'on_the_way':
              return UserCreatedAuctionEnum.onTheWay;
            case 'delivered':
              return UserCreatedAuctionEnum.delivered;
          }
        }
        return UserCreatedAuctionEnum.purchaseComplete;
    }
  }
}