import 'package:flutter/cupertino.dart';
import 'package:user_app/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/contact_us/domain/models/contact_us_body.dart';
import 'package:user_app/features/contact_us/domain/services/contact_us_service_interface.dart';
import 'package:user_app/helper/api_checker.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/main.dart';

class ContactUsController extends ChangeNotifier{
  ContactUsServiceInterface contactUsServiceInterface;
  ContactUsController({required this.contactUsServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> contactUs(ContactUsBody contactUsBody) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await contactUsServiceInterface.add(contactUsBody);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      showCustomSnackBarWidget(getTranslated('message_sent_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
    } else {
      _isLoading = false;
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();

    return apiResponse.response?.statusCode == 200;
  }

}