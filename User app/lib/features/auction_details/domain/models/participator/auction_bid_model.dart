class AuctionBidRequestModel {
  final int auctionProductId;
  final double bidAmount;
  final bool isAutoBid;
  final String? currencyCode;

  AuctionBidRequestModel({
    required this.auctionProductId,
    required this.bidAmount,
    this.isAutoBid = false,
    this.currencyCode,
  });

  Map<String, dynamic> toJson() => {
    'auction_product_id': auctionProductId,
    'bid_amount': bidAmount,
    'is_auto_bid': isAutoBid,
    'currency_code': currencyCode,
  };
}