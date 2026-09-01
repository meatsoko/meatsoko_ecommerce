// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/features/auction_list/domain/models/auction_product_model.dart';

class UserCreatedAuctionListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<UserCreatedAuctionProduct>? products;
  AuctionCounts? counts;

  UserCreatedAuctionListModel({this.totalSize, this.limit, this.offset, this.products, this.counts});

  UserCreatedAuctionListModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse('${json['total_size']}');
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    if (json['products'] != null) {
      products = <UserCreatedAuctionProduct>[];
      json['products'].forEach((v) => products!.add(UserCreatedAuctionProduct.fromJson(v)));
    }
    counts = json['counts'] != null ? AuctionCounts.fromJson(json['counts']) : null;
  }
}

class AuctionCounts {
  int total;
  int upcoming;
  int live;
  int readyToClaim;
  int purchaseComplete;
  int readyToDelivery;
  int onTheWay;
  int delivered;
  int unsold;
  int canceled;

  AuctionCounts({
    this.total = 0,
    this.upcoming = 0,
    this.live = 0,
    this.readyToClaim = 0,
    this.purchaseComplete = 0,
    this.readyToDelivery = 0,
    this.onTheWay = 0,
    this.delivered = 0,
    this.unsold = 0,
    this.canceled = 0,
  });

  AuctionCounts.fromJson(Map<String, dynamic> json)
      : total = int.tryParse('${json['total']}') ?? 0,
        upcoming = int.tryParse('${json['upcoming']}') ?? 0,
        live = int.tryParse('${json['live']}') ?? 0,
        readyToClaim = int.tryParse('${json['ready_to_claim']}') ?? 0,
        purchaseComplete = int.tryParse('${json['purchase_complete']}') ?? 0,
        readyToDelivery = int.tryParse('${json['ready_to_delivery']}') ?? 0,
        onTheWay = int.tryParse('${json['on_the_way']}') ?? 0,
        delivered = int.tryParse('${json['delivered']}') ?? 0,
        unsold = int.tryParse('${json['unsold']}') ?? 0,
        canceled = int.tryParse('${json['canceled']}') ?? 0;
}

class UserCreatedAuctionDetails {
  String? startTime;
  String? endTime;
  String? status;
  String? deliveryStatus;
  double? highestBidAmount;
  int? totalBids;
  int? totalParticipants;
  int? totalViews;

  UserCreatedAuctionDetails({
    this.startTime,
    this.endTime,
    this.status,
    this.deliveryStatus,
    this.highestBidAmount,
    this.totalBids,
    this.totalParticipants,
    this.totalViews,
  });

  UserCreatedAuctionDetails.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    deliveryStatus = json['delivery_status'];
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse('${json['highest_bid_amount']}') : null;
    totalBids = json['total_bids'];
    totalParticipants = json['total_participants'];
    totalViews = json['total_views'];
  }
}

class ClaimTransaction {
  String? paymentStatus;

  ClaimTransaction({this.paymentStatus});

  ClaimTransaction.fromJson(Map<String, dynamic> json) {
    paymentStatus = json['payment_status'];
  }
}

class UserCreatedAuctionProduct {
  int? id;
  String? slug;
  String? name;
  double? startingPrice;
  bool? isRelaunched;
  double? adminCommission;
  bool? isAdminCommissionPaid;
  ThumbnailFullUrl? thumbnailFullUrl;
  UserCreatedAuctionDetails? auctionDetails;
  ClaimTransaction? claimTransaction;

  UserCreatedAuctionProduct({
    this.id,
    this.slug,
    this.name,
    this.startingPrice,
    this.isRelaunched,
    this.adminCommission,
    this.isAdminCommissionPaid,
    this.thumbnailFullUrl,
    this.auctionDetails,
    this.claimTransaction,
  });

  UserCreatedAuctionProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    startingPrice = json['starting_price'] != null ? double.tryParse('${json['starting_price']}') : null;
    isRelaunched = json['is_relaunched'];
    adminCommission = json['admin_commission'] != null ? double.tryParse('${json['admin_commission']}') : null;
    isAdminCommissionPaid = json['admin_commission_given'];
    thumbnailFullUrl = json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null;
    auctionDetails = json['auction_details'] != null ? UserCreatedAuctionDetails.fromJson(json['auction_details']) : null;
    claimTransaction = json['claim_transaction'] != null ? ClaimTransaction.fromJson(json['claim_transaction']) : null;
  }
}
