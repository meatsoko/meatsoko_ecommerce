import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';

class CustomerAuctionListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<CustomerAuctionProduct>? products;
  AuctionCounts? counts;

  CustomerAuctionListModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
    this.counts,
  });

  CustomerAuctionListModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse('${json['total_size']}');
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    if (json['products'] != null) {
      products = <CustomerAuctionProduct>[];
      json['products'].forEach((v) {
        products!.add(CustomerAuctionProduct.fromJson(v));
      });
    }
    counts = json['counts'] != null ? AuctionCounts.fromJson(json['counts']) : null;
  }
}

class CustomerAuctionProduct {
  int? id;
  String? slug;
  String? name;
  double? startingPrice;
  double? highestBidAmount;
  double? shippingFee;
  double? totalTaxAmount;
  int? totalViews;
  int? totalParticipantsCount;
  AuctionParticipationStatus? auctionStatus;
  AuctionCurrentStatus? currentAuctionStatus;
  String? startTime;
  String? endTime;
  MyBid? myBid;
  ThumbnailFullUrl? thumbnailFullUrl;
  String? trackingUrl;
  bool? isOutbid;

  CustomerAuctionProduct({
    this.id,
    this.slug,
    this.name,
    this.startingPrice,
    this.highestBidAmount,
    this.shippingFee,
    this.totalTaxAmount,
    this.totalViews,
    this.totalParticipantsCount,
    this.auctionStatus,
    this.currentAuctionStatus,
    this.startTime,
    this.endTime,
    this.myBid,
    this.thumbnailFullUrl,
    this.trackingUrl,
    this.isOutbid,
  });

  CustomerAuctionProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    startingPrice = json['starting_price'] != null ? double.tryParse('${json['starting_price']}') : null;
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse('${json['highest_bid_amount']}') : null;
    shippingFee = json['shipping_fee'] != null ? double.tryParse('${json['shipping_fee']}') : null;
    totalTaxAmount = json['total_tax_amount'] != null ? double.tryParse('${json['total_tax_amount']}') : null;
    totalViews = json['total_views'];
    totalParticipantsCount = json['total_participants_count'];
    auctionStatus = AuctionParticipationStatus.fromString(json['my_auction_status']);
    currentAuctionStatus = AuctionCurrentStatus.fromString(json['auction_current_status']);
    startTime = json['start_time'];
    endTime = json['end_time'];
    myBid = json['my_bid'] != null ? MyBid.fromJson(json['my_bid']) : null;
    thumbnailFullUrl = json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null;
    trackingUrl = json['tracking_url'];
    isOutbid = json['is_outbid'];
  }
  bool get hasMyBid => myBid != null;
}

class AuctionCounts {
  int all;
  int participated;
  int live;
  int won;
  int claimed;
  int lost;
  int claimExpiredLost;

  AuctionCounts({
    this.all = 0,
    this.participated = 0,
    this.live = 0,
    this.won = 0,
    this.claimed = 0,
    this.lost = 0,
    this.claimExpiredLost = 0,
  });

  AuctionCounts.fromJson(Map<String, dynamic> json)
      : all = json['all'] ?? 0,
        participated = json['participated'] ?? 0,
        live = json['live'] ?? 0,
        won = json['won'] ?? 0,
        claimed = json['claimed'] ?? 0,
        lost = json['lost'] ?? 0,
        claimExpiredLost = json['claim_expired_lost'] ?? 0;

  int countForIndex(int index) {
    switch (index) {
      case 0: return all;
      case 1: return participated;
      case 2: return live;
      case 3: return won;
      case 4: return claimed;
      case 5: return lost;
      case 6: return claimExpiredLost;
      default: return 0;
    }
  }

  List<int?> toCountList() => [participated, live, won, claimed, lost, claimExpiredLost];
}

class MyBid {
  final int? id;
  final double? bidAmount;

  MyBid({this.id, this.bidAmount});

  factory MyBid.fromJson(Map<String, dynamic> json) {
    return MyBid(
      id: json['id'],
      bidAmount: json['bid_amount'] != null ? double.tryParse(json['bid_amount'].toString()) : null,
    );
  }
}

class ThumbnailFullUrl {
  String? key;
  String? path;
  int? status;

  ThumbnailFullUrl({this.key, this.path, this.status});

  ThumbnailFullUrl.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    path = json['path'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['path'] = path;
    data['status'] = status;
    return data;
  }
}