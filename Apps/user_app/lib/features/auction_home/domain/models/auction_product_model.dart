class AuctionProductListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<AuctionProduct>? products;

  AuctionProductListModel({this.totalSize, this.limit, this.offset, this.products});

  AuctionProductListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['products'] != null) {
      products = <AuctionProduct>[];
      json['products'].forEach((v) => products!.add(AuctionProduct.fromJson(v)));
    }
  }
}

class AuctionProduct {
  int? id;
  String? slug;
  int? shopId;
  String? name;
  int? categoryId;
  int? brandId;
  double? startingPrice;
  ThumbnailFullUrl? thumbnailFullUrl;
  AuctionDetails? auctionDetails;

  AuctionProduct({
    this.id,
    this.slug,
    this.shopId,
    this.name,
    this.categoryId,
    this.brandId,
    this.startingPrice,
    this.thumbnailFullUrl,
    this.auctionDetails,
  });

  AuctionProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    shopId = json['shop_id'];
    name = json['name'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    startingPrice = json['starting_price'] != null ? double.tryParse(json['starting_price'].toString()) : null;
    thumbnailFullUrl = json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null;
    auctionDetails = json['auction_details'] != null ? AuctionDetails.fromJson(json['auction_details']) : null;
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