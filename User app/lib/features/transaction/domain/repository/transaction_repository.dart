import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/commission_pay_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/repository/transaction_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class TransactionRepository implements TransactionRepositoryInterface {
  final DioClient? dioClient;

  TransactionRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getWithdrawMethodList() async {
    try {
      final response = await dioClient!.get(AppConstants.withdrawMethodListUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> payCommission({required CommissionPayRequestModel commissionPayRequest,
  }) async {
    try {
      final response = await dioClient!.post('${AppConstants.auctionCommissionPayUri}${commissionPayRequest.auctionProductId}', data: commissionPayRequest.toJson());
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> storeOrUpdateWithdraw({
    required int auctionProductId,
    required int withdrawMethodId,
    int? existingWithdrawId,
    double? amount,
    Map<String, dynamic>? methodInfo,
    String? transactionNote,
    String? currentCurrencyCode,
  }) async {
    try {
      final Map<String, dynamic> fields = {};
      fields['auction_product_id'] = auctionProductId;
      fields['withdraw_method_id'] = withdrawMethodId;
      if (existingWithdrawId != null) fields['existing_withdraw_id'] = existingWithdrawId;
      if (amount != null) fields['amount'] = amount;
      if (methodInfo != null) fields['method_info'] = methodInfo;
      if (transactionNote != null) fields['transaction_note'] = transactionNote;
      if (currentCurrencyCode != null) fields['current_currency_code'] = currentCurrencyCode;

      final response = await dioClient!.post(
        AppConstants.auctionWithdrawStoreOrUpdateUri,
        data: fields,
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) => throw UnimplementedError();
  @override
  Future delete(int id) => throw UnimplementedError();
  @override
  Future get(String id) => throw UnimplementedError();
  @override
  Future getList({int? offset = 1}) => throw UnimplementedError();
  @override
  Future update(Map<String, dynamic> body, int id) => throw UnimplementedError();
}