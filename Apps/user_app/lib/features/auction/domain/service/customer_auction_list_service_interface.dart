abstract class CustomerAuctionListServiceInterface {
  Future<dynamic> getCustomerAuctionList({
    required int limit,
    required int offset,
    String? status,
    String? auctionStatus,
  });

  Future<dynamic> getCustomerSavedAuctionList({
    required int limit,
    required int offset,
  });
}