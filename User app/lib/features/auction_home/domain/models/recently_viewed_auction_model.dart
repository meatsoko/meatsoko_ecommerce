import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';

class RecentlyViewedAuctionModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<RecentlyViewedItem>? recentViews;

  RecentlyViewedAuctionModel({this.totalSize, this.limit, this.offset, this.recentViews});

  RecentlyViewedAuctionModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['recent_views'] != null) {
      recentViews = <RecentlyViewedItem>[];
      json['recent_views'].forEach((v) => recentViews!.add(RecentlyViewedItem.fromJson(v)));
    }
  }
}

class RecentlyViewedItem {
  int? id;
  int? auctionProductId;
  RecentlyViewedProduct? auctionProduct;

  RecentlyViewedItem({this.id, this.auctionProductId, this.auctionProduct});

  RecentlyViewedItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    auctionProductId = json['auction_product_id'];
    auctionProduct = json['auctionProduct'] != null
        ? RecentlyViewedProduct.fromJson(json['auctionProduct'])
        : null;
  }
}

class RecentlyViewedProduct {
  int? id;
  String? slug;
  String? name;
  double? startingPrice;
  ThumbnailFullUrl? thumbnailFullUrl;
  AuctionDetails? auctionDetails;
  AuctionParticipationStatus? auctionStatus;
  AuctionCurrentStatus? currentAuctionStatus;
  String? trackingUrl;
  double? shippingFee;
  double? totalTaxAmount;

  RecentlyViewedProduct({
    this.id,
    this.slug,
    this.name,
    this.startingPrice,
    this.thumbnailFullUrl,
    this.auctionDetails,
    this.auctionStatus,
    this.currentAuctionStatus,
    this.trackingUrl,
    this.shippingFee,
    this.totalTaxAmount,
  });

  RecentlyViewedProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    startingPrice = json['starting_price'] != null ? double.tryParse(json['starting_price'].toString()) : null;
    thumbnailFullUrl = json['thumbnail_full_url'] != null
        ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url'])
        : null;
    auctionDetails = json['auction_details'] != null
        ? AuctionDetails.fromJson(json['auction_details'])
        : null;
    auctionStatus = AuctionParticipationStatus.fromString(json['auction_status']?.toString());
    currentAuctionStatus = AuctionCurrentStatus.fromString(json['auction_current_status']?.toString());
    trackingUrl = json['tracking_url'];
    shippingFee = json['shipping_fee'] != null ? double.tryParse(json['shipping_fee'].toString()) : null;
    totalTaxAmount = json['total_tax_amount'] != null ? double.tryParse(json['total_tax_amount'].toString()) : null;
  }
}

class AuctionDetails {
  String? startTime;
  String? endTime;
  double? highestBidAmount;
  int? totalBids;
  int? totalParticipants;
  int? totalViews;
  String? status;

  AuctionDetails({
    this.startTime,
    this.endTime,
    this.highestBidAmount,
    this.totalBids,
    this.totalParticipants,
    this.totalViews,
    this.status,
  });

  AuctionDetails.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse(json['highest_bid_amount'].toString()) : null;
    totalBids = json['total_bids'];
    totalParticipants = json['total_participants'];
    totalViews = json['total_views'];
    status = json['status']?.toString();
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