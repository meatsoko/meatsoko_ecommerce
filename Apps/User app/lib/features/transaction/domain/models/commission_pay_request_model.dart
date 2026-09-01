class CommissionPayRequestModel {
  final int auctionProductId;
  final double feeAmount;
  final String currencyCode;
  final String paymentMethod;
  final int? methodId;
  final String? methodName;
  final Map<String, String>? methodInformations;
  final String? paymentNote;
  final String? externalRedirectLink;

  CommissionPayRequestModel({
    required this.auctionProductId,
    required this.feeAmount,
    required this.currencyCode,
    required this.paymentMethod,
    this.methodId,
    this.methodName,
    this.methodInformations,
    this.paymentNote,
    this.externalRedirectLink,
  });

  Map<String, dynamic> toJson() => {
    'auction_product_id': auctionProductId,
    'fee_amount': feeAmount,
    'current_currency_code': currencyCode,
    'payment_method': paymentMethod,
    'payment_platform': 'app',
    if (methodId != null) 'method_id': methodId,
    if (methodName != null) 'method_name': methodName,
    if (methodInformations != null) 'method_informations': methodInformations,
    if (paymentNote != null && paymentNote!.isNotEmpty) 'payment_note': paymentNote,
    if (externalRedirectLink != null) 'external_redirect_link': externalRedirectLink,
  };
}
