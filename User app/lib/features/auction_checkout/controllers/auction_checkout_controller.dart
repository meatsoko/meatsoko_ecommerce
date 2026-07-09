import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/domain/services/auction_checkout_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';

class AuctionCheckoutController with ChangeNotifier {
  final AuctionCheckoutServiceInterface auctionCheckoutServiceInterface;
  AuctionCheckoutController({required this.auctionCheckoutServiceInterface});

  int? _addressIndex;
  int? _billingAddressIndex;
  int? get billingAddressIndex => _billingAddressIndex;
  int? get addressIndex => _addressIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _paymentMethodIndex = -1;
  int get paymentMethodIndex => _paymentMethodIndex;

  bool _sameAsBilling = false;
  bool get sameAsBilling => _sameAsBilling;

  bool _isWalletChecked = false;
  bool get isWalletChecked => _isWalletChecked;

  bool _isOfflineChecked = false;
  bool get isOfflineChecked => _isOfflineChecked;

  bool _isCODChecked = false;
  bool get isCODChecked => _isCODChecked;

  String _selectedDigitalPaymentMethodName = '';
  String get selectedDigitalPaymentMethodName =>
      _selectedDigitalPaymentMethodName;

  bool _isAcceptTerms = false;
  bool get isAcceptTerms => _isAcceptTerms;

  TextEditingController orderNoteController = TextEditingController();
  List<TextEditingController> inputFieldControllerList = [];
  List <String?> keyList = [];
  int offlineMethodSelectedId = 0;
  String offlineMethodSelectedName = '';

  void setAddressIndex(int i) {
    _addressIndex = i;
    notifyListeners();
  }

  void setBillingAddressIndex(int i) {
    _billingAddressIndex = i;
    notifyListeners();
  }

  void setSameAsBilling({bool isUpdate = true}) {
    _sameAsBilling = !_sameAsBilling;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void setPaymentMethod(int i) {
    _paymentMethodIndex = i;
    _isWalletChecked = false;
    _isOfflineChecked = false;
    _isCODChecked = false;
    notifyListeners();
  }

  void setWalletChecked() {
    _isWalletChecked = true;
    _isOfflineChecked = false;
    _isCODChecked = false;
    _paymentMethodIndex = -1;
    notifyListeners();
  }

  void setOfflineChecked(String type) {
    if (type == 'offline') {
      _isOfflineChecked = !_isOfflineChecked;
      if (_isOfflineChecked) {
        _isWalletChecked = false;
        _paymentMethodIndex = -1;
        _isCODChecked = false;
      }
    } else if (type == 'wallet') {
      _isWalletChecked = !_isWalletChecked;
      if (_isWalletChecked) {
        _isOfflineChecked = false;
        _paymentMethodIndex = -1;
        _isCODChecked = false;
      }
    } else if (type == 'cod') {
      _isCODChecked = !_isCODChecked;
      if (_isCODChecked) {
        _isOfflineChecked = false;
        _isWalletChecked = false;
        _paymentMethodIndex = -1;
      }
    }
    notifyListeners();
  }

  void updatePaymentSelection() {
    notifyListeners();
  }

  void setDigitalPaymentMethodName(int index, String name) {
    _paymentMethodIndex = index;
    _selectedDigitalPaymentMethodName = name;
    _isOfflineChecked = false;
    _isWalletChecked = false;
    _isCODChecked = false;
    notifyListeners();
  }

  void toggleTermsCheck({bool isUpdate = true}) {
    _isAcceptTerms = !_isAcceptTerms;
    if (isUpdate) notifyListeners();
  }

  void clearData() {
    _addressIndex = null;
    _billingAddressIndex = null;
    _sameAsBilling = false;
    _paymentMethodIndex = -1;
    _isWalletChecked = false;
    _isOfflineChecked = false;
    _isCODChecked = false;
    _isAcceptTerms = false;
    _selectedDigitalPaymentMethodName = '';
    orderNoteController.clear();
    inputFieldControllerList.clear();
    keyList.clear();
  }

  ({int addressId, int? billingAddressId,
    Map<String, dynamic> shippingAddressInfo, Map<String, dynamic> billingAddressInfo,
  })? getAddressData(List<AddressModel> addressList, bool billingEnabled) {
    if (_addressIndex == null) return null;

    final shipping = addressList[_addressIndex!];
    final hasSeparateBilling = billingEnabled && !_sameAsBilling && _billingAddressIndex != null;
    final billing = hasSeparateBilling ? addressList[_billingAddressIndex!] : shipping;

    Map<String, dynamic> toMap(AddressModel m) => {
      'contact_person_name': m.contactPersonName,
      'phone': m.phone,
      'address': m.address,
      'city': m.city,
      'zip': m.zip,
      'country': m.country,
    };

    return (
      addressId: shipping.id!,
      billingAddressId: hasSeparateBilling ? billing.id : null,
      shippingAddressInfo: toMap(shipping),
      billingAddressInfo: toMap(billing),
    );
  }

  Future<void> claimAuction({
    required int auctionProductId,
    required String paymentMethod,
    required String paymentPlatform,
    required String currentCurrencyCode,
    required int addressId,
    required Map<String, dynamic> shippingAddressInfo,
    int? billingAddressId,
    required Map<String, dynamic> billingAddressInfo,
    String? paymentNote,
    int? methodId,
    String? methodName,
    Map<String, String>? methodInformations,
    required Function(bool isSuccess, String message, String? redirectLink) callback,
  }) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> data = {
      'auction_product_id': auctionProductId,
      'payment_method': paymentMethod,
      'payment_platform': paymentPlatform,
      'current_currency_code': currentCurrencyCode,
      'address_id': addressId,
      if (billingAddressId != null) 'billing_address_id': billingAddressId,
      'billing_same_as_shipping': _sameAsBilling ? 1 : 0,
      'shipping_address_info': {
        'contact_person_name': shippingAddressInfo['contact_person_name'],
        'phone': shippingAddressInfo['phone'],
        'address': shippingAddressInfo['address'],
        'city': shippingAddressInfo['city'],
        'zip': shippingAddressInfo['zip'],
        'country': shippingAddressInfo['country'],
      },
      'billing_address_info': {
        'contact_person_name': billingAddressInfo['contact_person_name'],
        'phone': billingAddressInfo['phone'],
        'address': billingAddressInfo['address'],
        'city': billingAddressInfo['city'],
        'zip': billingAddressInfo['zip'],
        'country': billingAddressInfo['country'],
      },
      if (methodId != null) 'method_id': methodId,
      if (methodName != null) 'method_name': methodName,
      if (methodInformations != null) 'method_informations': methodInformations,
      if (paymentNote != null && paymentNote.isNotEmpty)
        'payment_note': paymentNote,
    };

    ApiResponseModel response = await auctionCheckoutServiceInterface.claimAuction(data);

    if (response.response != null && response.response!.statusCode == 200) {
      String message = 'auction_claimed_successfully';
      String? redirectLink;
      if (response.response!.data is Map) {
        if (response.response!.data['message'] != null) {
          message = response.response!.data['message'];
        }
        if (response.response!.data['redirect_link'] != null) {
          redirectLink = response.response!.data['redirect_link'];
        }
      }
      callback(true, message, redirectLink);
    } else {
      String? errorMessage;
      if (response.error is String) {
        errorMessage = response.error.toString();
      } else {
        errorMessage = response.response?.data['message']?.toString();
      }
      callback(false, errorMessage ?? 'Failed to claim auction', null);
    }

    _isLoading = false;
    notifyListeners();
  }

  OfflinePaymentModel? offlinePaymentModel;
  int _offlineMethodSelectedIndex = 0;
  int get offlineMethodSelectedIndex => _offlineMethodSelectedIndex;

  Future<ApiResponseModel> getOfflinePaymentList() async {
    ApiResponseModel apiResponse =
    await auctionCheckoutServiceInterface.offlinePaymentList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      offlinePaymentModel = OfflinePaymentModel.fromJson(apiResponse.response?.data);
      setOfflinePaymentMethodSelectedIndex(0, notify: false);
    }
    notifyListeners();
    return apiResponse;
  }

  void setOfflinePaymentMethodSelectedIndex(int index, {bool notify = true}) {
    keyList = [];
    inputFieldControllerList = [];
    _offlineMethodSelectedIndex = index;
    if (offlinePaymentModel != null &&
        offlinePaymentModel!.offlineMethods != null &&
        offlinePaymentModel!.offlineMethods!.isNotEmpty) {
      offlineMethodSelectedId =
          offlinePaymentModel!.offlineMethods![_offlineMethodSelectedIndex].id!;
      offlineMethodSelectedName = offlinePaymentModel!
          .offlineMethods![_offlineMethodSelectedIndex].methodName!;
    }

    if (offlinePaymentModel!.offlineMethods != null &&
        offlinePaymentModel!.offlineMethods!.isNotEmpty &&
        offlinePaymentModel!.offlineMethods![index].methodInformations!.isNotEmpty) {
      for (int i = 0; i < offlinePaymentModel!.offlineMethods![index].methodInformations!.length; i++) {
        inputFieldControllerList.add(TextEditingController());
        keyList.add(offlinePaymentModel!.offlineMethods![index].methodInformations![i].customerInput);
      }
    }
    if (notify) {
      notifyListeners();
    }
  }
}
