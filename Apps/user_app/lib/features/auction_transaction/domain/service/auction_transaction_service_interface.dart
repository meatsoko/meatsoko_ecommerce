// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
abstract class AuctionTransactionServiceInterface {
  Future getAuctionTransactionList({
    int? searchAuctionId,
    int limit = 10,
    int offset = 1,
    String? filterBy,
    String? filterDurationType,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future getSalesReport({required String dateType, String? startDate, String? endDate});
}
