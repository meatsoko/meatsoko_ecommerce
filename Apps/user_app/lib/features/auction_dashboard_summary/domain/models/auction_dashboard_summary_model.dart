// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
class AuctionDashboardSummaryModel {
  int? totalMyBids;
  int? totalMySavedAuctions;
  int? totalMyAuctions;
  int? totalMyAuctionPending;

  AuctionDashboardSummaryModel({
    this.totalMyBids,
    this.totalMySavedAuctions,
    this.totalMyAuctions,
    this.totalMyAuctionPending,
  });

  AuctionDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    totalMyBids = json['total_my_bids'];
    totalMySavedAuctions = json['total_my_saved_auctions'];
    totalMyAuctions = json['total_my_auctions'];
    totalMyAuctionPending = json['total_my_auction_pending'];
  }
}
