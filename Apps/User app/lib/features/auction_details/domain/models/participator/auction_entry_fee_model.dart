class AuctionEntryFeeRequestModel {
  final int auctionProductId;
  final double feeAmount;
  final String currency;
  final String? paymentMethod;
  final int? methodId;
  final String? methodName;
  final Map<String, String>? methodInformations;
  final String? paymentNote;

  AuctionEntryFeeRequestModel({
    required this.auctionProductId,
    required this.feeAmount,
    required this.currency,
    required this.paymentMethod,
    this.methodId,
    this.methodName,
    this.methodInformations,
    this.paymentNote,
  });

  Map<String, dynamic> toJson() => {
    'auction_product_id': auctionProductId,
    'fee_amount': feeAmount,
    'current_currency_code': currency,
    'payment_method': paymentMethod,
    'payment_platform': 'app',
    if (methodId != null) 'method_id': methodId,
    if (methodName != null) 'method_name': methodName,
    if (methodInformations != null) 'method_informations': methodInformations,
    if (paymentNote != null && paymentNote!.isNotEmpty) 'payment_note': paymentNote,
  };
}

class AuctionParticipantModel {
  final int? id;
  final int? auctionProductId;
  final int? userId;
  final bool? entryFeePaidStatus;
  final String? entryFeePaidAmount;
  final String? status;
  final String? joinedAt;
  final String? createdAt;
  final String? updatedAt;

  AuctionParticipantModel({
    this.id,
    this.auctionProductId,
    this.userId,
    this.entryFeePaidStatus,
    this.entryFeePaidAmount,
    this.status,
    this.joinedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AuctionParticipantModel.fromJson(Map<String, dynamic> json) {
    return AuctionParticipantModel(
      id: json['id'],
      auctionProductId: json['auction_product_id'],
      userId: json['user_id'],
      entryFeePaidStatus: json['entry_fee_paid_status'],
      entryFeePaidAmount: json['entry_fee_paid_amount'],
      status: json['status'],
      joinedAt: json['joined_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AuctionTransactionModel {
  final int? id;
  final int? auctionProductId;
  final int? userId;
  final String? type;
  final String? amount;
  final String? currency;
  final String? paymentStatus;
  final String? createdAt;
  final String? updatedAt;

  AuctionTransactionModel({
    this.id,
    this.auctionProductId,
    this.userId,
    this.type,
    this.amount,
    this.currency,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory AuctionTransactionModel.fromJson(Map<String, dynamic> json) {
    return AuctionTransactionModel(
      id: json['id'],
      auctionProductId: json['auction_product_id'],
      userId: json['user_id'],
      type: json['type'],
      amount: json['amount'],
      currency: json['currency'],
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AuctionEntryFeeResponseModel {
  final String? message;
  final AuctionParticipantModel? participant;
  final AuctionTransactionModel? transaction;

  AuctionEntryFeeResponseModel({
    this.message,
    this.participant,
    this.transaction,
  });

  factory AuctionEntryFeeResponseModel.fromJson(Map<String, dynamic> json) {
    return AuctionEntryFeeResponseModel(
      message: json['message'],
      participant: json['participant'] != null
          ? AuctionParticipantModel.fromJson(json['participant'])
          : null,
      transaction: json['transaction'] != null
          ? AuctionTransactionModel.fromJson(json['transaction'])
          : null,
    );
  }
}