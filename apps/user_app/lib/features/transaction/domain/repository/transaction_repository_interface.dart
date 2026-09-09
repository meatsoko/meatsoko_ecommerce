import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/transaction/domain/models/commission_pay_request_model.dart';
import 'package:user_app/interface/repo_interface.dart';

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