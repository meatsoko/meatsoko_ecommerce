import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/commission_pay_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class TransactionRepositoryInterface implements RepositoryInterface {
  Future<ApiResponseModel> getWithdrawMethodList();

  Future<ApiResponseModel> payCommission({required CommissionPayRequestModel commissionPayRequest});

  Future<ApiResponseModel> storeOrUpdateWithdraw({
    required int auctionProductId,
    required int withdrawMethodId,
    int? existingWithdrawId,
    double? amount,
    Map<String, dynamic>? methodInfo,
    String? transactionNote,
    String? currentCurrencyCode,
  });
}