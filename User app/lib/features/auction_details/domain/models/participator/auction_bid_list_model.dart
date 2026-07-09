class AuctionBidListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<AuctionBidItem>? bids;

  AuctionBidListModel(
      {this.totalSize, this.limit, this.offset, this.bids});

  AuctionBidListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['bids'] != null) {
      bids = <AuctionBidItem>[];
      json['bids'].forEach((v) {
        bids!.add(AuctionBidItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (bids != null) {
      data['bids'] = bids!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AuctionBidItem {
  int? id;
  int? auctionProductId;
  int? userId;
  double? bidAmount;
  bool? isAutoBid;
  bool? isWithdrawBid;
  String? bidTime;
  String? claimStartTime;
  String? createdAt;
  String? updatedAt;
  bool? isLeadBid;
  bool? isMyBid;
  Customer? customer;
  UserContext? userContext;

  AuctionBidItem(
    {this.id,
      this.auctionProductId,
      this.userId,
      this.bidAmount,
      this.isAutoBid,
      this.isWithdrawBid,
      this.bidTime,
      this.claimStartTime,
      this.createdAt,
      this.updatedAt,
      this.isLeadBid,
      this.isMyBid,
      this.customer,
      this.userContext});

  AuctionBidItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    auctionProductId = json['auction_product_id'];
    userId = json['user_id'];
    bidAmount = json['bid_amount'] != null ? double.tryParse(json['bid_amount'].toString()) : null;
    isAutoBid = json['is_auto_bid'];
    isWithdrawBid = json['is_withdraw_bid'];
    bidTime = json['bid_time'];
    claimStartTime = json['claim_start_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isLeadBid = json['is_lead_bid'];
    isMyBid = json['is_my_bid'];
    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
    userContext = json['user_context'] != null
        ? UserContext.fromJson(json['user_context'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['auction_product_id'] = auctionProductId;
    data['user_id'] = userId;
    data['bid_amount'] = bidAmount;
    data['is_auto_bid'] = isAutoBid;
    data['is_withdraw_bid'] = isWithdrawBid;
    data['bid_time'] = bidTime;
    data['claim_start_time'] = claimStartTime;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_lead_bid'] = isLeadBid;
    data['is_my_bid'] = isMyBid;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (userContext != null) {
      data['user_context'] = userContext!.toJson();
    }
    return data;
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? image;
  ImageFullUrl? imageFullUrl;

  Customer({this.id, this.fName, this.lName, this.image, this.imageFullUrl});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    image = json['image'];
    imageFullUrl = json['image_full_url'] != null
        ? ImageFullUrl.fromJson(json['image_full_url'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['image'] = image;
    if (imageFullUrl != null) {
      data['image_full_url'] = imageFullUrl!.toJson();
    }
    return data;
  }
}

class ImageFullUrl {
  String? key;
  String? path;
  int? status;

  ImageFullUrl({this.key, this.path, this.status});

  ImageFullUrl.fromJson(Map<String, dynamic> json) {
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

class UserContext {
  int? myPosition;
  bool? isLeading;
  bool? isWinner;
  String? claimEndTime;
  double? claimTimeRemaining;
  bool? isClaimExpired;

  UserContext(
    {this.myPosition,
      this.isLeading,
      this.isWinner,
      this.claimEndTime,
      this.claimTimeRemaining,
      this.isClaimExpired});

  UserContext.fromJson(Map<String, dynamic> json) {
    myPosition = json['my_position'];
    isLeading = json['is_leading'];
    isWinner = json['is_winner'];
    claimEndTime = json['claim_end_time'];
    claimTimeRemaining = json['claim_time_remaining'] != null ? double.tryParse(json['claim_time_remaining'].toString()) : null;
    isClaimExpired = json['is_claim_expired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['my_position'] = myPosition;
    data['is_leading'] = isLeading;
    data['is_winner'] = isWinner;
    data['claim_end_time'] = claimEndTime;
    data['claim_time_remaining'] = claimTimeRemaining;
    data['is_claim_expired'] = isClaimExpired;
    return data;
  }
}
