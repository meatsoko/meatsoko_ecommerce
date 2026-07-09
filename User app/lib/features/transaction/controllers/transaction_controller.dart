import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/commission_pay_request_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/commission_pay_response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/withdraw_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/withdraw_store_or_update_response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/service/transaction_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';

class TransactionController extends ChangeNotifier {
  final TransactionServiceInterface transactionServiceInterface;

  TransactionController({required this.transactionServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<WithdrawMethodModel> _withdrawMethods = [];
  List<WithdrawMethodModel> get withdrawMethods => _withdrawMethods;

  bool _isCommissionPayLoading = false;
  bool get isCommissionPayLoading => _isCommissionPayLoading;
  String? _commissionPayRedirectLink;
  String? get commissionPayRedirectLink => _commissionPayRedirectLink;

  bool _isWithdrawLoading = false;
  bool get isWithdrawLoading => _isWithdrawLoading;
  WithdrawStoreOrUpdateResponseModel? _withdrawResponse;
  WithdrawStoreOrUpdateResponseModel? get withdrawResponse => _withdrawResponse;
  String? _withdrawMethodName;
  String? get withdrawMethodName => _withdrawMethodName;
  String? _withdrawAccountDisplay;
  String? get withdrawAccountDisplay => _withdrawAccountDisplay;

  Future<void> getWithdrawMethodList(BuildContext context) async {
    _isLoading = true;
    _withdrawMethods = [];
    notifyListeners();

    final response = await transactionServiceInterface.getWithdrawMethodList();

    if (response?.response?.statusCode == 200) {
      final data = response?.response?.data;
      if (data is List) {
        _withdrawMethods = data.map((e) => WithdrawMethodModel.fromJson(e)).toList();
      }
    } else {
      ApiChecker.checkApi(response!);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> payCommission(
    BuildContext context, {
    required int auctionProductId,
    required double feeAmount,
    required String currencyCode,
    required String paymentMethod,
    String? paymentNote,
    int? methodId,
    String? methodName,
    Map<String, String>? methodInformations,
    String? externalRedirectLink,
  }) async {
    _isCommissionPayLoading = true;
    _commissionPayRedirectLink = null;
    notifyListeners();

    final response = await transactionServiceInterface.payCommission(
      commissionPayRequest: CommissionPayRequestModel(
        auctionProductId: auctionProductId,
        feeAmount: feeAmount,
        currencyCode: currencyCode,
        paymentMethod: paymentMethod,
        paymentNote: paymentNote,
        methodId: methodId,
        methodName: methodName,
        methodInformations: methodInformations,
        externalRedirectLink: externalRedirectLink,
      ),
    );

    if (response?.response?.statusCode == 200) {
      final data = CommissionPayResponseModel.fromJson(response.response.data);
      _commissionPayRedirectLink = data.redirectLink;
      if (_commissionPayRedirectLink == null) {
        showCustomSnackBarWidget(getTranslated('commission_paid_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
      }
    } else if (response?.response?.statusCode == 404) {
      showCustomSnackBarWidget(getTranslated('auction_not_found_or_not_owned', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    } else if (response?.response?.statusCode == 409) {
      showCustomSnackBarWidget(getTranslated('commission_already_paid', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    } else if (response?.response?.statusCode == 422) {
      showCustomSnackBarWidget(getTranslated('commission_no_due_or_missing_phone', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    } else if (response?.response?.statusCode == 403) {
      showCustomSnackBarWidget(getTranslated('auction_not_in_payable_status', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    } else {
      ApiChecker.checkApi(response!);
    }

    _isCommissionPayLoading = false;
    notifyListeners();
  }

  Future<void> storeOrUpdateWithdraw(
    BuildContext context, {
    required int auctionProductId,
    required int withdrawMethodId,
    int? existingWithdrawId,
    double? amount,
    Map<String, dynamic>? methodInfo,
    String? transactionNote,
    String? displayMethodName,
    String? displayAccountInfo,
  }) async {
    _isWithdrawLoading = true;
    _withdrawResponse = null;
    notifyListeners();

    final String? currentCurrencyCode = Provider.of<SplashController>(context, listen: false).myCurrency?.code;

    final response = await transactionServiceInterface.storeOrUpdateWithdraw(
      auctionProductId: auctionProductId,
      withdrawMethodId: withdrawMethodId,
      existingWithdrawId: existingWithdrawId,
      amount: amount,
      methodInfo: methodInfo,
      transactionNote: transactionNote,
      currentCurrencyCode: currentCurrencyCode,
    );

    if (response?.response?.statusCode == 200) {
      _withdrawResponse = WithdrawStoreOrUpdateResponseModel.fromJson(response.response.data);
      _withdrawMethodName = displayMethodName;
      _withdrawAccountDisplay = displayAccountInfo;
      final message = existingWithdrawId != null ? 'withdrawal_request_updated_successfully' : 'withdrawal_request_submitted_successfully';
      showCustomSnackBarWidget(getTranslated(message, Get.context!), Get.context!, snackBarType: SnackBarType.success);
    } else if (response?.response?.statusCode == 404) {
      showCustomSnackBarWidget(getTranslated('auction_not_found_or_not_owned', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    } else if (response?.response?.statusCode == 403) {
      showCustomSnackBarWidget(getTranslated('withdrawal_method_not_enabled', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    } else if (response?.response?.statusCode == 409) {
      showCustomSnackBarWidget(getTranslated('active_withdrawal_already_exists', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    } else if (response?.response?.statusCode == 422) {
      showCustomSnackBarWidget(getTranslated('auction_not_eligible_for_withdrawal', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    } else {
      ApiChecker.checkApi(response!);
    }

    _isWithdrawLoading = false;
    notifyListeners();
  }
}