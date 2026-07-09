import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/commission_pay_request_model.dart';

abstract class TransactionServiceInterface {
  Future<dynamic> getWithdrawMethodList();

  Future<dynamic> payCommission({
    required CommissionPayRequestModel commissionPayRequest,
  });

  Future<dynamic> storeOrUpdateWithdraw({
    required int auctionProductId,
    required int withdrawMethodId,
    int? existingWithdrawId,
    double? amount,
    Map<String, dynamic>? methodInfo,
    String? transactionNote,
    String? currentCurrencyCode,
  });
}