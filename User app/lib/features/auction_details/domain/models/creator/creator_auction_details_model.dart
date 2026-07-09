import 'dart:convert';
import 'package:flutter_sixvalley_ecommerce/common/enums/user_created_auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_list/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/domain/models/brand_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/models/vat_tax_type_model.dart';

class CreatorAuctionDetailsModel {
  CreatorAuctionProduct? product;
  DeliveredPayout? deliveredPayout;
  AuctionWithdrawModel? auctionWithdraw;

  CreatorAuctionDetailsModel({this.product});

  CreatorAuctionDetailsModel.fromJson(Map<String, dynamic> json) {
    product = json['product'] != null ? CreatorAuctionProduct.fromJson(json['product']) : null;
    deliveredPayout = json['delivered_payout'] != null ? DeliveredPayout.fromJson(json['delivered_payout']) : null;
    auctionWithdraw = json['auction_withdraw'] != null ? AuctionWithdrawModel.fromJson(json['auction_withdraw']) : null;
  }
}

class CreatorAuctionProduct {
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
  String? youtubeVideoUrl;
  ThumbnailFullUrl? customVideoUrlFullUrl;
  String? previewFile;
  String? startTime;
  String? endTime;
  String? status;
  String? approvalStatus;
  String? deliveryStatus;
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
  BrandModel? brand;
  CategoryModel? category;
  dynamic highestBid;
  dynamic winningBid;
  dynamic winner;
  List<dynamic>? participants;
  List<AuctionTransaction>? transactions;
  AuctionSeoInfo? seoInfo;
  List<Translations>? translations;
  List<TaxVats>? taxVats;
  AuctionAddressInfo? shippingAddressInfo;
  AuctionAddressInfo? billingAddressInfo;
  int? shippingAddressId;
  int? billingAddress;
  double? adminCommission;
  bool? isAdminCommissionPaid;
  String? trackingUrl;
  bool? isSameAddress;
  List<String>? tags;

  double get minBidAmount => (highestBidAmount ?? 0) + (minimumIncrementAmount ?? 0);

  CreatorAuctionProduct({
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
    this.youtubeVideoUrl,
    this.customVideoUrlFullUrl,
    this.previewFile,
    this.startTime,
    this.endTime,
    this.status,
    this.approvalStatus,
    this.deliveryStatus,
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
    this.participants,
    this.transactions,
    this.seoInfo,
    this.translations,
    this.taxVats,
    this.shippingAddressId,
    this.shippingAddressInfo,
    this.billingAddressInfo,
    this.billingAddress,
    this.adminCommission,
    this.isAdminCommissionPaid,
    this.trackingUrl,
    this.isSameAddress,
    this.tags,
  });

  CreatorAuctionProduct.fromJson(Map<String, dynamic> json) {
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
    youtubeVideoUrl = json['youtube_video_url'];
    customVideoUrlFullUrl = json['custom_video_url_full_url'] != null ? ThumbnailFullUrl.fromJson(json['custom_video_url_full_url']) : null;
    previewFile = json['preview_file'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status']?.toString();
    approvalStatus = json['approval_status'];
    deliveryStatus = json['delivery_status'];
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
    brand = json['brand'] != null ? BrandModel.fromJson(json['brand']) : null;
    category = json['category'] != null ? CategoryModel.fromJson(json['category']) : null;
    highestBid = json['highest_bid'];
    winningBid = json['winning_bid'];
    winner = json['winner'];
    participants = json['participants'] != null ? List<dynamic>.from(json['participants']) : null;
    if (json['transactions'] != null) {
      transactions = <AuctionTransaction>[];
      json['transactions'].forEach((v) {transactions!.add(AuctionTransaction.fromJson(v));});
    }
    seoInfo = json['seo_info'] != null ? AuctionSeoInfo.fromJson(json['seo_info']) : null;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
    if (json['tax_vats'] != null) {
      taxVats = <TaxVats>[];
      json['tax_vats'].forEach((v) {
        taxVats!.add(TaxVats.fromJson(v));
      });
    }
    shippingAddressId = json['shipping_address_id'];
    shippingAddressInfo = json['shipping_address_info'] != null ? AuctionAddressInfo.fromJson(json['shipping_address_info']) : null;
    billingAddress = json['billing_address'];
    billingAddressInfo = json['billing_address_info'] != null ? AuctionAddressInfo.fromJson(json['billing_address_info']) : null;
    adminCommission = json['admin_commission'] != null ? double.tryParse('${json['admin_commission']}') : null;
    isAdminCommissionPaid = json['admin_commission_given'];
    trackingUrl = json['tracking_url'];
    isSameAddress = json['billing_same_as_shipping'];
    if (json['tags'] is List) {
      tags = (json['tags'] as List)
          .map((e) => e is Map ? (e['tag'] ?? e['name'] ?? '').toString() : e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (json['tags'] is String && (json['tags'] as String).isNotEmpty) {
      tags = (json['tags'] as String).split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
  }

  UserCreatedAuctionEnum get auctionState => UserCreatedAuctionEnum.resolve(
    approvalStatus: approvalStatus,
    auctionStatus: auctionStatus,
    deliveryStatus: deliveryStatus,
  );

  bool get hasPendingOfflineCommissionPayment =>
    transactions?.any((t) =>
      t.type == 'commission_payment' && t.paymentMethod == 'offline_payment' && t.paymentStatus == 'pending') ?? false;
}

class AuctionSeoInfo {
  int? id;
  String? seoableType;
  int? seoableId;
  String? title;
  String? description;
  String? index;
  String? noFollow;
  String? noImageIndex;
  String? noArchive;
  String? noSnippet;
  String? maxSnippet;
  String? maxSnippetValue;
  String? maxVideoPreview;
  String? maxVideoPreviewValue;
  String? maxImagePreview;
  String? maxImagePreviewValue;
  String? image;
  String? createdAt;
  String? updatedAt;
  ThumbnailFullUrl? imageFullUrl;

  AuctionSeoInfo({
    this.id,
    this.seoableType,
    this.seoableId,
    this.title,
    this.description,
    this.index,
    this.noFollow,
    this.noImageIndex,
    this.noArchive,
    this.noSnippet,
    this.maxSnippet,
    this.maxSnippetValue,
    this.maxVideoPreview,
    this.maxVideoPreviewValue,
    this.maxImagePreview,
    this.maxImagePreviewValue,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.imageFullUrl,
  });

  AuctionSeoInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    seoableType = json['seoable_type'];
    seoableId = json['seoable_id'];
    title = json['title'];
    description = json['description'];
    index = json['index'];
    noFollow = json['no_follow'];
    noImageIndex = json['no_image_index'];
    noArchive = json['no_archive'];
    noSnippet = json['no_snippet'] != null ? '${json['no_snippet']}' : null;
    maxSnippet = json['max_snippet'] != null ? '${json['max_snippet']}' : null;
    maxSnippetValue = json['max_snippet_value'] != null ? '${json['max_snippet_value']}' : null;
    maxVideoPreview = json['max_video_preview'] != null ? '${json['max_video_preview']}' : null;
    maxVideoPreviewValue = json['max_video_preview_value'] != null ? '${json['max_video_preview_value']}' : null;
    maxImagePreview = json['max_image_preview'] != null ? '${json['max_image_preview']}' : null;
    maxImagePreviewValue = json['max_image_preview_value'] != null ? '${json['max_image_preview_value']}' : null;
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageFullUrl = json['image_full_url'] != null ? ThumbnailFullUrl.fromJson(json['image_full_url']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['seoable_type'] = seoableType;
    data['seoable_id'] = seoableId;
    data['title'] = title;
    data['description'] = description;
    data['index'] = index;
    data['no_follow'] = noFollow;
    data['no_image_index'] = noImageIndex;
    data['no_archive'] = noArchive;
    data['no_snippet'] = noSnippet;
    data['max_snippet'] = maxSnippet;
    data['max_snippet_value'] = maxSnippetValue;
    data['max_video_preview'] = maxVideoPreview;
    data['max_video_preview_value'] = maxVideoPreviewValue;
    data['max_image_preview'] = maxImagePreview;
    data['max_image_preview_value'] = maxImagePreviewValue;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (imageFullUrl != null) data['image_full_url'] = imageFullUrl!.toJson();
    return data;
  }
}

class AuctionAddressInfo {
  String? contactPersonName;
  String? phone;
  String? address;
  String? city;
  String? zip;
  String? country;

  AuctionAddressInfo({
    this.contactPersonName,
    this.phone,
    this.address,
    this.city,
    this.zip,
    this.country,
  });

  AuctionAddressInfo.fromJson(Map<String, dynamic> json) {
    contactPersonName = json['contact_person_name'];
    phone = json['phone'];
    address = json['address'];
    city = json['city'];
    zip = json['zip'];
    country = json['country'];
  }
}

class TransactionMethodInformations {
  final String? mobileNumber;
  final String? transactionId;
  final String? date;
  final String? reference;

  TransactionMethodInformations({this.mobileNumber, this.transactionId, this.date, this.reference});

  factory TransactionMethodInformations.fromJson(Map<String, dynamic> json) => TransactionMethodInformations(
    mobileNumber: json['mobile_number']?.toString(),
    transactionId: json['transaction_id']?.toString(),
    date: json['date']?.toString(),
    reference: json['reference']?.toString(),
  );
}

class AuctionTransactionPaymentInfo {
  final String? paymentNote;
  final int? methodId;
  final String? methodName;
  final TransactionMethodInformations? methodInformations;

  AuctionTransactionPaymentInfo({this.paymentNote, this.methodId, this.methodName, this.methodInformations});

  factory AuctionTransactionPaymentInfo.fromJson(Map<String, dynamic> json) => AuctionTransactionPaymentInfo(
    paymentNote: json['payment_note']?.toString(),
    methodId: json['method_id'] != null ? int.tryParse(json['method_id'].toString()) : null,
    methodName: json['method_name']?.toString(),
    methodInformations: json['method_informations'] != null
        ? TransactionMethodInformations.fromJson(json['method_informations'])
        : null,
  );
}

class AuctionTransaction {
  int? id;
  int? auctionProductId;
  int? userId;
  int? bidId;
  String? type;
  double? amount;
  String? currencyCode;
  String? paymentMethod;
  AuctionTransactionPaymentInfo? paymentInfo;
  String? paymentStatus;
  String? transactionRef;
  String? createdAt;
  String? updatedAt;

  AuctionTransaction({
    this.id,
    this.auctionProductId,
    this.userId,
    this.bidId,
    this.type,
    this.amount,
    this.currencyCode,
    this.paymentMethod,
    this.paymentInfo,
    this.paymentStatus,
    this.transactionRef,
    this.createdAt,
    this.updatedAt,
  });

  AuctionTransaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    auctionProductId = json['auction_product_id'];
    userId = json['user_id'];
    bidId = json['bid_id'];
    type = json['type'];
    amount = json['amount'] != null ? double.tryParse('${json['amount']}') : null;
    currencyCode = json['currency_code'];
    paymentMethod = json['payment_method'];
    paymentInfo = json['payment_info'] != null
        ? AuctionTransactionPaymentInfo.fromJson(
            json['payment_info'] is String
                ? Map<String, dynamic>.from(jsonDecode(json['payment_info']))
                : json['payment_info'] as Map<String, dynamic>)
        : null;
    paymentStatus = json['payment_status'];
    transactionRef = json['transaction_ref'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class AuctionWithdrawModel {
  final int? id;
  final int? auctionProductId;
  final double? amount;
  final double? commissionAmount;
  final int? withdrawalMethodId;
  final Map<String, dynamic>? withdrawalMethodFields;
  final String? transactionNote;
  final String? status;

  AuctionWithdrawModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        auctionProductId = json['auction_product_id'] as int?,
        amount = json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
        commissionAmount = json['commission_amount'] != null ? double.tryParse(json['commission_amount'].toString()) : null,
        withdrawalMethodId = json['withdrawal_method_id'] as int?,
        withdrawalMethodFields = json['withdrawal_method_fields'] as Map<String, dynamic>?,
        transactionNote = json['transaction_note'] as String?,
        status = json['status'] as String?;
}

class DeliveredPayout {
  String? claimPaymentMethod;
  PayoutBreakdown? breakdown;

  DeliveredPayout({this.claimPaymentMethod, this.breakdown});

  DeliveredPayout.fromJson(Map<String, dynamic> json) {
    claimPaymentMethod = json['claim_payment_method'];
    breakdown = json['breakdown'] != null
        ? PayoutBreakdown.fromJson(json['breakdown'])
        : null;
  }
}

class PayoutBreakdown {
  double? bidAmount;
  double? shippingFee;
  double? taxAmount;
  String? taxType;
  double? totalPayable;
  double? commissionPercentage;
  double? commissionAmount;
  double? vendorReceivable;

  PayoutBreakdown({
    this.bidAmount,
    this.shippingFee,
    this.taxAmount,
    this.taxType,
    this.totalPayable,
    this.commissionPercentage,
    this.commissionAmount,
    this.vendorReceivable,
  });

  PayoutBreakdown.fromJson(Map<String, dynamic> json) {
    bidAmount        = double.tryParse('${json['bid_amount']}');
    shippingFee      = double.tryParse('${json['shipping_fee']}');
    taxAmount        = double.tryParse('${json['tax_amount']}');
    taxType          = json['tax_type'];
    totalPayable     = double.tryParse('${json['total_payable']}');
    commissionPercentage = double.tryParse('${json['commission_percentage']}');
    commissionAmount = double.tryParse('${json['commission_amount']}');
    vendorReceivable = double.tryParse('${json['vendor_receivable']}');
  }
}