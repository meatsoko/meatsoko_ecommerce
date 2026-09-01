abstract class AuctionCheckoutServiceInterface {
  Future<dynamic> claimAuction(Map<String, dynamic> data);
  Future<dynamic> offlinePaymentList();
}
