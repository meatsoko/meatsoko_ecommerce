enum AuctionDeliveryStatus {
  readyToDelivery('ready_to_delivery'),
  onTheWay('on_the_way'),
  delivered('delivered');

  const AuctionDeliveryStatus(this.value);
  final String value;

  static AuctionDeliveryStatus? fromValue(String? value) {
    for (final status in AuctionDeliveryStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}