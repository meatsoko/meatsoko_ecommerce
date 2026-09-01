// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/common/enums/auction_enum.dart';
import 'package:user_app/common/enums/payment_status_enum.dart';
import 'package:user_app/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:user_app/features/auction_list/domain/models/auction_product_model.dart';

enum AuctionOwnerType {
  admin,
  seller,
  customer;

  static AuctionOwnerType? fromString(String? value) {
    switch (value) {
      case 'admin':
        return AuctionOwnerType.admin;
      case 'seller':
        return AuctionOwnerType.seller;
      case 'customer':
        return AuctionOwnerType.customer;
      default:
        return null;
    }
  }
}

class ParticipationAuctionDetailsModel {
  AuctionProductDetails? product;
  PaymentInfo? paymentInfo;
  BillingInfo? billingInfo;
  List<SimilarProduct>? similarProducts;
  List<SameAuthorProduct>? sameAuthorProducts;

  ParticipationAuctionDetailsModel({
    this.product,
    this.paymentInfo,
    this.billingInfo,
    this.similarProducts,
    this.sameAuthorProducts,
  });

  ParticipationAuctionDetailsModel.fromJson(Map<String, dynamic> json) {
    product = json['product'] != null ? AuctionProductDetails.fromJson(json['product']) : null;
    paymentInfo = json['payment_info'] != null ? PaymentInfo.fromJson(json['payment_info']) : null;
    billingInfo = json['billing_info'] != null ? BillingInfo.fromJson(json['billing_info']) : null;
    if (json['similar_products'] != null) {
      similarProducts = <SimilarProduct>[];
      json['similar_products'].forEach((v) => similarProducts!.add(SimilarProduct.fromJson(v)));
    }
    if (json['same_author_products'] != null) {
      sameAuthorProducts = <SameAuthorProduct>[];
      json['same_author_products'].forEach((v) => sameAuthorProducts!.add(SameAuthorProduct.fromJson(v)));
    }
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
}

class MyBid {
  int? id;
  double? bidAmount;
  bool? isLeadBid;
  bool? isRollbackBid;
  bool? isWithdrawBid;
  String? claimStartTime;
  String? bidTime;

  MyBid({
    this.id,
    this.bidAmount,
    this.isLeadBid,
    this.isRollbackBid,
    this.isWithdrawBid,
    this.claimStartTime,
    this.bidTime,
  });

  MyBid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bidAmount = json['bid_amount'] != null ? double.tryParse('${json['bid_amount']}') : null;
    isLeadBid = json['is_lead_bid'];
    isRollbackBid = json['is_rollback_bid'];
    isWithdrawBid = json['is_withdraw_bid'];
    claimStartTime = json['claim_start_time'];
    bidTime = json['bid_time'];
  }
}

class SecondHighestBid {
  double? bidAmount;

  SecondHighestBid({this.bidAmount});

  SecondHighestBid.fromJson(Map<String, dynamic> json) {
    bidAmount = json['bid_amount'] != null ? double.tryParse('${json['bid_amount']}') : null;
  }
}

class MyParticipation {
  String? entryFeePaymentMethod;
  String? entryFeePaidStatus;
  String? entryFeePaymentStatus;
  double? entryFeePaidAmount;
  String? entryFeeDeniedNote;
  AuctionTransaction? auctionTransaction;

  MyParticipation({
    this.entryFeePaymentMethod,
    this.entryFeePaidStatus,
    this.entryFeePaymentStatus,
    this.entryFeePaidAmount,
    this.entryFeeDeniedNote,
    this.auctionTransaction,
  });

  MyParticipation.fromJson(Map<String, dynamic> json) {
    entryFeePaymentMethod = json['entry_fee_payment_method'];
    entryFeePaidStatus = json['entry_fee_paid_status']?.toString();
    entryFeePaymentStatus = json['entry_fee_payment_status'];
    entryFeePaidAmount = json['entry_fee_paid_amount'] != null ? double.tryParse('${json['entry_fee_paid_amount']}') : null;
    entryFeeDeniedNote = json['entry_fee_denied_note'];
    auctionTransaction = json['auction_transaction'] != null ? AuctionTransaction.fromJson(json['auction_transaction']) : null;
  }
}

class AuctionInsights {
  int? totalBids;
  double? avgBidIncrease;
  double? highestJump;

  AuctionInsights({this.totalBids, this.avgBidIncrease, this.highestJump});

  AuctionInsights.fromJson(Map<String, dynamic> json) {
    totalBids = json['total_bids'];
    avgBidIncrease = json['avg_bid_increase'] != null ? double.tryParse('${json['avg_bid_increase']}') : null;
    highestJump = json['highest_jump'] != null ? double.tryParse('${json['highest_jump']}') : null;
  }
}

class OwnerInfo {
  int? id;
  String? fName;
  String? lName;
  ThumbnailFullUrl? imageFullUrl;

  OwnerInfo({this.id, this.fName, this.lName, this.imageFullUrl});

  OwnerInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    imageFullUrl = json['image_full_url'] != null ? ThumbnailFullUrl.fromJson(json['image_full_url']) : null;
  }
}

class AuctionProductDetails {
  int? id;
  String? slug;
  String? name;
  String? details;
  int? categoryId;
  String? itemCondition;
  String? returnPolicy;
  String? videoProvider;
  String? youtubeVideoUrl;
  ThumbnailFullUrl? customVideoUrlFullUrl;
  double? startingPrice;
  double? currentHighestBidAmount;
  double? highestBidAmount;
  double? minimumIncrementAmount;
  double? shippingFee;
  double? totalTaxAmount;
  String? startTime;
  String? endTime;
  int? totalViews;
  int? totalBidsCount;
  int? totalParticipantsCount;
  bool? isAllBidWithdrawn;
  bool? isAuctionSave;
  bool? isOutbid;
  bool? isSameAddress;
  String? trackingUrl;
  int? ownerId;
  AuctionOwnerType? ownerType;
  String? auctionOwnerStatus;
  AuctionParticipationStatus? auctionStatus;
  AuctionParticipationStatus? myAuctionStatus;
  AuctionCurrentStatus? currentAuctionStatus;
  ThumbnailFullUrl? thumbnailFullUrl;
  List<ThumbnailFullUrl>? imagesFullUrl;
  MyBid? myBid;
  MyParticipation? myParticipation;
  SecondHighestBid? secondHighestBid;
  AuctionInsights? auctionInsights;
  OwnerInfo? ownerInfo;
  AuctionAddressInfo? shippingAddressInfo;
  AuctionAddressInfo? billingAddressInfo;

  AuctionProductDetails({
    this.id,
    this.slug,
    this.name,
    this.details,
    this.categoryId,
    this.itemCondition,
    this.returnPolicy,
    this.videoProvider,
    this.youtubeVideoUrl,
    this.customVideoUrlFullUrl,
    this.startingPrice,
    this.currentHighestBidAmount,
    this.highestBidAmount,
    this.minimumIncrementAmount,
    this.shippingFee,
    this.totalTaxAmount,
    this.startTime,
    this.endTime,
    this.totalViews,
    this.totalBidsCount,
    this.totalParticipantsCount,
    this.isAllBidWithdrawn,
    this.isAuctionSave,
    this.isOutbid,
    this.isSameAddress,
    this.trackingUrl,
    this.ownerId,
    this.ownerType,
    this.auctionOwnerStatus,
    this.auctionStatus,
    this.myAuctionStatus,
    this.currentAuctionStatus,
    this.thumbnailFullUrl,
    this.imagesFullUrl,
    this.myBid,
    this.myParticipation,
    this.secondHighestBid,
    this.auctionInsights,
    this.ownerInfo,
    this.shippingAddressInfo,
    this.billingAddressInfo,
  });

  AuctionProductDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    details = json['details'];
    categoryId = json['category_id'];
    itemCondition = json['item_condition'];
    returnPolicy = json['return_policy'];
    videoProvider = json['video_provider'];
    youtubeVideoUrl = json['youtube_video_url'];
    customVideoUrlFullUrl = json['custom_video_url_full_url'] != null ? ThumbnailFullUrl.fromJson(json['custom_video_url_full_url']) : null;
    startingPrice = json['starting_price'] != null ? double.tryParse('${json['starting_price']}') : null;
    currentHighestBidAmount = json['current_highest_bid_amount'] != null ? double.tryParse('${json['current_highest_bid_amount']}') : null;
    highestBidAmount = json['highest_bid_amount'] != null ? double.tryParse('${json['highest_bid_amount']}') : null;
    minimumIncrementAmount = json['minimum_increment_amount'] != null ? double.tryParse('${json['minimum_increment_amount']}') : null;
    shippingFee = json['shipping_fee'] != null ? double.tryParse('${json['shipping_fee']}') : null;
    totalTaxAmount = json['total_tax_amount'] != null ? double.tryParse('${json['total_tax_amount']}') : null;
    startTime = json['start_time'];
    endTime = json['end_time'];
    totalViews = json['total_views'];
    totalBidsCount = json['total_bids_count'];
    totalParticipantsCount = json['total_participants_count'];
    isAllBidWithdrawn = json['is_all_bid_withdrawn'];
    isAuctionSave = json['is_auction_save'];
    isOutbid = json['is_outbid'];
    isSameAddress = json['billing_same_as_shipping'];
    trackingUrl = json['tracking_url'];
    ownerId = json['owner_id'];
    ownerType = AuctionOwnerType.fromString(json['owner_type']);
    auctionOwnerStatus = json['auction_owner_status'];
    auctionStatus = AuctionParticipationStatus.fromString(json['auction_status']);
    myAuctionStatus = AuctionParticipationStatus.fromString(json['my_auction_status']);
    currentAuctionStatus = AuctionCurrentStatus.fromString(json['current_auction_status']);
    thumbnailFullUrl = json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null;
    if (json['images_full_url'] != null) {
      imagesFullUrl = <ThumbnailFullUrl>[];
      json['images_full_url'].forEach((v) => imagesFullUrl!.add(ThumbnailFullUrl.fromJson(v)));
    }
    myBid = json['my_bid'] != null ? MyBid.fromJson(json['my_bid']) : null;
    myParticipation = json['my_participation'] != null ? MyParticipation.fromJson(json['my_participation']) : null;
    secondHighestBid = json['second_highest_bid'] != null ? SecondHighestBid.fromJson(json['second_highest_bid']) : null;
    auctionInsights = json['auction_insights'] != null ? AuctionInsights.fromJson(json['auction_insights']) : null;
    ownerInfo = json['owner_info'] != null ? OwnerInfo.fromJson(json['owner_info']) : null;
    shippingAddressInfo = json['shipping_address_info'] != null ? AuctionAddressInfo.fromJson(json['shipping_address_info']) : null;
    billingAddressInfo = json['billing_address_info'] != null ? AuctionAddressInfo.fromJson(json['billing_address_info']) : null;
  }
}

class PaymentInfo {
  PaymentStatus? paymentStatus;
  String? paymentMethod;
  double? paidAmount;

  PaymentInfo({this.paymentStatus, this.paymentMethod, this.paidAmount});

  PaymentInfo.fromJson(Map<String, dynamic> json) {
    paymentStatus = PaymentStatus.fromString(json['payment_status']?.toString());
    paymentMethod = json['payment_method'];
    paidAmount = json['paid_amount'] != null ? double.tryParse('${json['paid_amount']}') : null;
  }
}

class BillingInfo {
  double? winningBid;
  double? shippingFee;
  double? taxAmount;

  BillingInfo({this.winningBid, this.shippingFee, this.taxAmount});

  BillingInfo.fromJson(Map<String, dynamic> json) {
    winningBid = json['winning_bid'] != null ? double.tryParse('${json['winning_bid']}') : null;
    shippingFee = json['shipping_fee'] != null ? double.tryParse('${json['shipping_fee']}') : null;
    taxAmount = json['tax_amount'] != null ? double.tryParse('${json['tax_amount']}') : null;
  }
}

class SimilarProduct {
  int? id;
  String? slug;
  String? name;
  double? startingPrice;
  AuctionParticipationStatus? auctionCurrentStatus;
  AuctionDetails? auctionDetails;
  ThumbnailFullUrl? thumbnailFullUrl;

  SimilarProduct({
    this.id,
    this.slug,
    this.name,
    this.startingPrice,
    this.auctionCurrentStatus,
    this.auctionDetails,
    this.thumbnailFullUrl,
  });

  SimilarProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    startingPrice = json['starting_price'] != null ? double.tryParse('${json['starting_price']}') : null;
    auctionCurrentStatus = AuctionParticipationStatus.fromString(json['auction_status']);
    auctionDetails = json['auction_details'] != null ? AuctionDetails.fromJson(json['auction_details']) : null;
    thumbnailFullUrl = json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null;
  }
}

class SameAuthorProduct {
  int? id;
  String? slug;
  String? name;
  double? startingPrice;
  AuctionParticipationStatus? auctionCurrentStatus;
  AuctionDetails? auctionDetails;
  ThumbnailFullUrl? thumbnailFullUrl;

  SameAuthorProduct({
    this.id,
    this.slug,
    this.name,
    this.startingPrice,
    this.auctionCurrentStatus,
    this.auctionDetails,
    this.thumbnailFullUrl,
  });

  SameAuthorProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    startingPrice = json['starting_price'] != null ? double.tryParse('${json['starting_price']}') : null;
    auctionCurrentStatus = AuctionParticipationStatus.fromString(json['auction_status']);
    auctionDetails = json['auction_details'] != null ? AuctionDetails.fromJson(json['auction_details']) : null;
    thumbnailFullUrl = json['thumbnail_full_url'] != null ? ThumbnailFullUrl.fromJson(json['thumbnail_full_url']) : null;
  }
}
