// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/material.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/auction_details/domain/services/participator/auction_participation_service_interface.dart';
import 'package:user_app/helper/api_checker.dart';

class SocialShareLinkModel {
  final String? link;
  SocialShareLinkModel({this.link});
}

class AuctionParticipationController extends ChangeNotifier {
  final AuctionParticipationServiceInterface auctionParticipationServiceInterface;
  AuctionParticipationController({required this.auctionParticipationServiceInterface});

  bool _isEntryFeeLoading = false;
  bool get isEntryFeeLoading => _isEntryFeeLoading;

  bool _isBidLoading = false;
  bool get isBidLoading => _isBidLoading;

  bool _isWithdrawBidLoading = false;
  bool get isWithdrawBidLoading => _isWithdrawBidLoading;

  bool _isRollbackBidLoading = false;
  bool get isRollbackBidLoading => _isRollbackBidLoading;

  bool _isSaveLoading = false;
  bool get isSaveLoading => _isSaveLoading;

  bool _isInvoiceLoading = false;
  bool get isInvoiceLoading => _isInvoiceLoading;

  bool _isEntryFeePaid = false;
  bool get isEntryFeePaid => _isEntryFeePaid;

  bool _isWalletApplied = false;
  bool get isWalletApplied => _isWalletApplied;

  bool _isWalletInsufficient = false;
  bool get isWalletInsufficient => _isWalletInsufficient;

  bool _isOfflinePaymentSelected = false;
  bool get isOfflinePaymentSelected => _isOfflinePaymentSelected;

  int? _selectedPaymentMethodIndex;
  int? get selectedPaymentMethodIndex => _selectedPaymentMethodIndex;

  String _selectedPaymentMethodName = '';
  String get selectedPaymentMethodName => _selectedPaymentMethodName;

  double? _minimumBidRequired;
  double? get minimumBidRequired => _minimumBidRequired;

  SocialShareLinkModel? _socialShareLink;
  SocialShareLinkModel? get socialShareLink => _socialShareLink;

  void clearMinimumBidRequired() {
    _minimumBidRequired = null;
    notifyListeners();
  }

  void resetPaymentState() {
    _isEntryFeeLoading = false;
    _isEntryFeePaid = false;
    _isWalletApplied = false;
    _isWalletInsufficient = false;
    _isOfflinePaymentSelected = false;
    _selectedPaymentMethodIndex = null;
    _selectedPaymentMethodName = '';
    notifyListeners();
  }

  void applyWallet({required double walletBalance, required double entryFee}) {
    _isWalletApplied = !_isWalletApplied;
    _isWalletInsufficient = _isWalletApplied && walletBalance < entryFee;
    notifyListeners();
  }

  void setSelectedPaymentMethod(int index, String keyName) {
    _selectedPaymentMethodIndex = index;
    _selectedPaymentMethodName = keyName;
    _isOfflinePaymentSelected = false;
    notifyListeners();
  }

  void setOfflinePaymentSelected(bool selected) {
    _isOfflinePaymentSelected = selected;
    if (selected) {
      _selectedPaymentMethodIndex = null;
      _selectedPaymentMethodName = '';
    }
    notifyListeners();
  }

  Future<ApiResponseModel?> placeAuctionBid(
    BuildContext context, {
    required int auctionProductId,
    required TextEditingController bidAmountController,
  }) async {
    _isBidLoading = true;
    notifyListeners();

    final double bidAmount = double.tryParse(bidAmountController.text) ?? 0.0;
    final ApiResponseModel response = await auctionParticipationServiceInterface.placeAuctionBid(
      auctionProductId: auctionProductId,
      bidAmount: bidAmount,
    );

    _isBidLoading = false;
    notifyListeners();

    if (!response.isSuccess && context.mounted) {
      ApiChecker.checkApi(response);
    }
    return response;
  }

  Future<ApiResponseModel?> rollbackAuctionBid(
    BuildContext context, {
    required int auctionProductId,
    required double bidAmount,
  }) async {
    _isRollbackBidLoading = true;
    notifyListeners();

    final ApiResponseModel response = await auctionParticipationServiceInterface.rollbackAuctionBid(
      auctionProductId: auctionProductId,
      bidAmount: bidAmount,
    );

    _isRollbackBidLoading = false;
    notifyListeners();

    if (!response.isSuccess && context.mounted) {
      ApiChecker.checkApi(response);
    }
    return response;
  }

  Future<ApiResponseModel?> withdrawAuctionBid(BuildContext context, {required int auctionProductId}) async {
    _isWithdrawBidLoading = true;
    notifyListeners();

    final ApiResponseModel response = await auctionParticipationServiceInterface.withdrawAuctionBid(auctionProductId: auctionProductId);

    _isWithdrawBidLoading = false;
    notifyListeners();

    if (!response.isSuccess && context.mounted) {
      ApiChecker.checkApi(response);
    }
    return response;
  }

  Future<ApiResponseModel?> payAuctionEntryFee(
    BuildContext context, {
    required int auctionProductId,
    required double feeAmount,
    required String currency,
    required String auctionStatus,
    required String paymentMethod,
    int? methodId,
    String? methodName,
    Map<String, String>? methodInformations,
    String? paymentNote,
  }) async {
    _isEntryFeeLoading = true;
    notifyListeners();

    final ApiResponseModel response = await auctionParticipationServiceInterface.payAuctionEntryFee(
      auctionProductId: auctionProductId,
      feeAmount: feeAmount,
      currency: currency,
      auctionStatus: auctionStatus,
      paymentMethod: paymentMethod,
      methodId: methodId,
      methodName: methodName,
      methodInformations: methodInformations,
      paymentNote: paymentNote,
    );

    _isEntryFeeLoading = false;
    _isEntryFeePaid = response.isSuccess;
    notifyListeners();

    if (!response.isSuccess && context.mounted) {
      ApiChecker.checkApi(response);
    }
    return response;
  }

  bool validateToggleSave(BuildContext context, {int? auctionProductId}) {
    return auctionProductId != null;
  }

  Future<void> toggleSaveAuctionProduct(BuildContext context, {required int auctionProductId}) async {
    _isSaveLoading = true;
    notifyListeners();

    final ApiResponseModel response = await auctionParticipationServiceInterface.toggleSaveAuctionProduct(auctionProductId: auctionProductId);

    _isSaveLoading = false;
    notifyListeners();

    if (!response.isSuccess && context.mounted) {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getAuctionSocialShareLink(BuildContext context, {required int productId}) async {
    final ApiResponseModel response = await auctionParticipationServiceInterface.getAuctionSocialShareLink(productId: productId);

    if (response.isSuccess) {
      _socialShareLink = SocialShareLinkModel();
    } else if (context.mounted) {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  Future<void> getAuctionInvoice(int productId, BuildContext context) async {
    _isInvoiceLoading = true;
    notifyListeners();

    final ApiResponseModel response = await auctionParticipationServiceInterface.getAuctionInvoice(productId: productId);

    _isInvoiceLoading = false;
    notifyListeners();

    if (!response.isSuccess && context.mounted) {
      ApiChecker.checkApi(response);
    }
  }
}
