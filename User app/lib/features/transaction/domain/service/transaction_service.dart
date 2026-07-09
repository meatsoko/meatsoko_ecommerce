import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/commission_pay_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/repository/transaction_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/service/transaction_service_interface.dart';

class TransactionService implements TransactionServiceInterface {
  final TransactionRepositoryInterface transactionRepositoryInterface;

  TransactionService({required this.transactionRepositoryInterface});

  @override
  Future getWithdrawMethodList() async {
    return await transactionRepositoryInterface.getWithdrawMethodList();
  }

  @override
  Future<dynamic> payCommission({
    required CommissionPayRequestModel commissionPayRequest,
  }) => transactionRepositoryInterface.payCommission(commissionPayRequest: commissionPayRequest);

  @override
  Future<dynamic> storeOrUpdateWithdraw({
    required int auctionProductId,
    required int withdrawMethodId,
    int? existingWithdrawId,
    double? amount,
    Map<String, dynamic>? methodInfo,
    String? transactionNote,
    String? currentCurrencyCode,
  }) => transactionRepositoryInterface.storeOrUpdateWithdraw(
    auctionProductId: auctionProductId,
    withdrawMethodId: withdrawMethodId,
    existingWithdrawId: existingWithdrawId,
    amount: amount,
    methodInfo: methodInfo,
    transactionNote: transactionNote,
    currentCurrencyCode: currentCurrencyCode,
  );
}