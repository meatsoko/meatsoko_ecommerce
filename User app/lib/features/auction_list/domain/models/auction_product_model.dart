import 'package:flutter_sixvalley_ecommerce/features/brand/domain/models/brand_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';

class AuctionProductListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<AuctionProduct>? products;
  Map<String, int>? counts;

  AuctionProductListModel({this.totalSize, this.limit, this.offset, this.products, this.counts});

  AuctionProductListModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse('${json['total_size']}');
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    if (json['products'] != null) {
      products = <AuctionProduct>[];
      json['products'].forEach((v) {
        products!.add(AuctionProduct.fromJson(v));
      });
    }
    if (json['counts'] != null) {
      counts = Map<String, int>.from(
        (json['counts'] as Map).map((k, v) => MapEntry(k as String, int.tryParse(v.toString()) ?? 0)),
      );
    }
  }
}

class AuctionProduct {
  int? id;
  String? ownerType;
  int? ownerId;
  int? shopId;
  String? name;
  String? details;
  String? slug;
  int? categoryId;
  int? brandId;
  String? productType;
  String? itemCondition;
  double? entryFee;
  double? startingPrice;
  double? minimumIncrementAmount;
  double? maximumDecrementAmount;
  double? shippingFee;
  String? returnPolicy;
  String? thumbnail;
  String? images;
  String? videoProvider;
  String? videoUrl;
  String? previewFile;
  String? startTime;
  String? endTime;
  String? status;
  String? approvalStatus;
  int? approvedByAdminId;
  String? approvedAt;
  String? rejectedNote;
  int? winnerUserId;
  int? winningBidId;
  double? currentHighestBidAmount;
  int? totalBids;
  int? totalParticipants;
  int? totalViews;
  String? createdAt;
  String? updatedAt;
  int? bidsCount;
  int? participantsCount;
  String? auctionStatus;
  double? highestBidAmount;
  int? totalBidsCount;
  int? totalParticipantsCount;
  AuctionDetails? auctionDetails;
  ThumbnailFullUrl? thumbnailFullUrl;
  ThumbnailFullUrl? previewFileFullUrl;
  ThumbnailFullUrl? metaImageFullUrl;
  List<ThumbnailFullUrl>? imagesFullUrl;
  Brand? brand;
  CategoryModel? category;
  dynamic highestBid;
  dynamic winningBid;
  dynamic winner;
  List<Translations>? translations;

  AuctionProduct({
    this.id,
    this.ownerType,
    this.ownerId,
    this.shopId,
    this.name,
    this.details,
    this.slug,
    this.categoryId,
    this.brandId,
    this.productType,
    this.itemCondition,
    this.entryFee,
    this.startingPrice,
    this.minimumIncrementAmount,
    this.maximumDecrementAmount,
    this.shippingFee,
    this.returnPolicy,
    this.thumbnail,
    this.images,
    this.videoProvider,
    this.videoUrl,
    this.previewFile,
    this.startTime,
    this.endTime,
    this.status,
    this.approvalStatus,
    this.approvedByAdminId,
    this.approvedAt,
    this.rejectedNote,
    this.winnerUserId,
    this.winningBidId,
    this.currentHighestBidAmount,
    this.totalBids,
    this.totalParticipants,
    this.totalViews,
    this.createdAt,
    this.updatedAt,
    this.bidsCount,
    this.participantsCount,
    this.auctionStatus,
    this.highestBidAmount,
    this.totalBidsCount,
    this.totalParticipantsCount,
    this.auctionDetails,
    this.thumbnailFullUrl,
    this.previewFileFullUrl,
    this.metaImageFullUrl,
    this.imagesFullUrl,
    this.brand,
    this.category,
    this.highestBid,
    this.winningBid,
    this.winner,
    this.translations,
  });

  AuctionProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerType = json['owner_type'];
    ownerId = json['owner_id'];
    shopId = json['shop_id'];
    name = json['name'];
    details = json['details'];
    slug = json['slug'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    productType = json['product_type'];
    itemCondition = json['item_condition'];
    entryFee = json['entry_fee'] != null ? double.tryParse('${json['entry_fee']}') : null;
    startingPrice = json['starting_price'] != null ? double.tryParse('${json['starting_price']}') : null;
    minimumIncrementAmount = json['minimum_increment_amount'] != null ? double.tryParse('${json['minimum_increment_amount']}') : null;
    maximumDecrementAmount = json['maximum_decrement_amount'] != null ? double.tryParse('${json['maximum_decrement_amount']}') : null;
    shippingFee = json['shipping_fee'] != null ? double.tryParse('${json['shipping_fee']}') : null;
    returnPolicy = json['return_policy'];
    thumbnail = json['thumbnail'];
    images = json['images'];
    videoProvider = json['video_provider'];
    videoUrl = json['video_url'];
    previewFile = json['preview_file'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status']?.toString();
    approvalStatus = json['approval_status'];
    approvedByAdminId = json['approved_by_admin_id'];
    approvedAt = json['approved_at'];
    rejectedNote = json['rejected_note'];
    winnerUserId = json['winner_user_id'];
    winningBidId = json['winning_bid_id'];
    currentHighestBidAmount = json['current_highest_bid_amount'] != null ? double.tryParse('${json['current_highest_bid_amount']}') : null;
    totalBids = json['total_bids'];
    totalParticipants = json['total_participants'];
    totalViews = json['total_views'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bidsCount = json['bids_count'];
    participantsCount = json['participants_count'];
    auctionStatus = json['auction_status'];
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse('${json['highest_bid_amount']}') : null;
    totalBidsCount = json['total_bids_count'];
    totalParticipantsCount = json['total_participants_count'];
    auctionDetails = json['auction_details'] != null ? AuctionDetails.fromJson(json['auction_details']) : null;
    thumbnailFullUrl = json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null;
    previewFileFullUrl = json['preview_file_full_url'] != null ? ThumbnailFullUrl.fromJson(json['preview_file_full_url']) : null;
    metaImageFullUrl = json['meta_image_full_url'] != null ? ThumbnailFullUrl.fromJson(json['meta_image_full_url']) : null;
    if (json['images_full_url'] != null) {
      imagesFullUrl = <ThumbnailFullUrl>[];
      json['images_full_url'].forEach((v) {
        imagesFullUrl!.add(ThumbnailFullUrl.fromJson(v));
      });
    }
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category = json['category'] != null ? CategoryModel.fromJson(json['category']) : null;
    highestBid = json['highest_bid'];
    winningBid = json['winning_bid'];
    winner = json['winner'];
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['owner_type'] = ownerType;
    data['owner_id'] = ownerId;
    data['shop_id'] = shopId;
    data['name'] = name;
    data['details'] = details;
    data['slug'] = slug;
    data['category_id'] = categoryId;
    data['brand_id'] = brandId;
    data['product_type'] = productType;
    data['item_condition'] = itemCondition;
    data['entry_fee'] = entryFee;
    data['starting_price'] = startingPrice;
    data['minimum_increment_amount'] = minimumIncrementAmount;
    data['maximum_decrement_amount'] = maximumDecrementAmount;
    data['shipping_fee'] = shippingFee;
    data['return_policy'] = returnPolicy;
    data['thumbnail'] = thumbnail;
    data['images'] = images;
    data['video_provider'] = videoProvider;
    data['video_url'] = videoUrl;
    data['preview_file'] = previewFile;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['status'] = status;
    data['approval_status'] = approvalStatus;
    data['approved_by_admin_id'] = approvedByAdminId;
    data['approved_at'] = approvedAt;
    data['rejected_note'] = rejectedNote;
    data['winner_user_id'] = winnerUserId;
    data['winning_bid_id'] = winningBidId;
    data['current_highest_bid_amount'] = currentHighestBidAmount;
    data['total_bids'] = totalBids;
    data['total_participants'] = totalParticipants;
    data['total_views'] = totalViews;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['bids_count'] = bidsCount;
    data['participants_count'] = participantsCount;
    data['auction_status'] = auctionStatus;
    data['highest_bid_amount'] = highestBidAmount;
    data['total_bids_count'] = totalBidsCount;
    data['total_participants_count'] = totalParticipantsCount;
    if (auctionDetails != null) data['auction_details'] = auctionDetails!.toJson();
    if (thumbnailFullUrl != null) data['thumbnail_full_url'] = thumbnailFullUrl!.toJson();
    if (previewFileFullUrl != null) data['preview_file_full_url'] = previewFileFullUrl!.toJson();
    if (metaImageFullUrl != null) data['meta_image_full_url'] = metaImageFullUrl!.toJson();
    if (imagesFullUrl != null) data['images_full_url'] = imagesFullUrl!.map((v) => v.toJson()).toList();
    if (brand != null) data['brand'] = brand!.toJson();
    if (category != null) data['category'] = category!.toJson();
    data['highest_bid'] = highestBid;
    data['winning_bid'] = winningBid;
    data['winner'] = winner;
    if (translations != null) data['translations'] = translations!.map((v) => v.toJson()).toList();
    return data;
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
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse('${json['highest_bid_amount']}') : null;
    totalBids = json['total_bids'];
    totalParticipants = json['total_participants'];
    totalViews = json['total_views'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['highest_bid_amount'] = highestBidAmount;
    data['total_bids'] = totalBids;
    data['total_participants'] = totalParticipants;
    data['total_views'] = totalViews;
    data['status'] = status;
    return data;
  }
}

class Translations {
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  int? id;

  Translations({
    this.translationableType,
    this.translationableId,
    this.locale,
    this.key,
    this.value,
    this.id,
  });

  Translations.fromJson(Map<String, dynamic> json) {
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['id'] = id;
    return data;
  }
}