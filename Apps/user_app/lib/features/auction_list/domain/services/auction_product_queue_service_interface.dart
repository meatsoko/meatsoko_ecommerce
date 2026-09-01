// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
abstract class AuctionProductQueueServiceInterface {
  Future getAuctionProductQueueList({
    required int offset,
    required String approvalStatus,
    int limit = 10,
  });

  Future deleteAuctionProduct(int id);
}
