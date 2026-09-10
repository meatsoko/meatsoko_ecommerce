import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:vendor_app/features/auth/domain/models/register_model.dart';
import 'package:vendor_app/features/auth/screens/auth_screen.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/account_info_page.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/owner_info_page.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/review_submit_page.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/shop_identity_page.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/tax_info_page.dart';
import 'package:vendor_app/features/auth/widgets/register_successfull_dialog_widget.dart';
import 'package:vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:vendor_app/helper/email_checker.dart';
import 'package:vendor_app/localization/language_constrants.dart';
import 'package:vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:vendor_app/main.dart';
import 'package:vendor_app/utill/dimensions.dart';
import 'package:vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:vendor_app/common/basewidgets/custom_snackbar_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  static const int _pageCount = 5;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = const [
    OwnerInfoPage(),
    AccountInfoPage(),
    ShopIdentityPage(),
    TaxInfoPage(),
    ReviewSubmitPage(),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<AuthController>(Get.context!, listen: false).setCountryDialCode(CountryCode.fromCountryCode(Provider.of<SplashController>(context, listen: false).configModel!.countryCode ?? '+880').dialCode);
    Provider.of<AuthController>(Get.context!, listen: false).emptyRegistrationData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    setState(() => _currentPage = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _handleBack() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    } else if (Navigator.of(Get.context!).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
    }
  }

  bool _validateCurrentPage(AuthController authController) {
    switch (_currentPage) {
      case 0: // Owner info
        if (authController.firstNameController.text.trim().isEmpty) {
          showCustomSnackBarWidget(getTranslated('first_name_is_required', context), context, sanckBarType: SnackBarType.warning);
          return false;
        } else if (authController.lastNameController.text.trim().isEmpty) {
          showCustomSnackBarWidget(getTranslated('last_name_is_required', context), context, sanckBarType: SnackBarType.warning);
          return false;
        } else if (authController.sellerProfileImage == null) {
          showCustomSnackBarWidget(getTranslated('profile_image_is_required', context), context, sanckBarType: SnackBarType.warning);
          return false;
        }
        return true;

      case 1: // Account
        if (authController.emailController.text.trim().isEmpty) {
          showCustomSnackBarWidget(getTranslated('email_is_required', context), context, sanckBarType: SnackBarType.warning);
        } else if (EmailChecker.isNotValid(authController.emailController.text.trim())) {
          showCustomSnackBarWidget(getTranslated('email_is_ot_valid', context), context, sanckBarType: SnackBarType.warning);
        } else if (authController.phoneController.text.trim().isEmpty) {
          showCustomSnackBarWidget(getTranslated('phone_is_required', context), context, sanckBarType: SnackBarType.warning);
        } else if (authController.phoneController.text.trim().length < 8) {
          showCustomSnackBarWidget(getTranslated('phone_number_is_not_valid', context), context, sanckBarType: SnackBarType.warning);
        } else if (authController.passwordController.text.trim().isEmpty) {
          showCustomSnackBarWidget(getTranslated('password_is_required', context), context, sanckBarType: SnackBarType.warning);
        } else if (authController.passwordController.text.trim().length < 8) {
          showCustomSnackBarWidget(getTranslated('password_minimum_length_is_6', context), context, sanckBarType: SnackBarType.warning);
        } else if (authController.confirmPasswordController.text.trim().isEmpty) {
          showCustomSnackBarWidget(getTranslated('confirm_password_is_required', context), context, sanckBarType: SnackBarType.warning);
        } else if (authController.passwordController.text.trim() != authController.confirmPasswordController.text.trim()) {
          showCustomSnackBarWidget(getTranslated('password_is_mismatch', context), context, sanckBarType: SnackBarType.warning);
        } else if (authController.passwordController.text.trim().isNotEmpty && !authController.isPasswordValid()) {
          showCustomSnackBarWidget(getTranslated('enter_valid_password', context), context, sanckBarType: SnackBarType.warning);
        } else {
          return true;
        }
        return false;

      case 2: // Shop identity
        if (authController.shopNameController.text.trim().isEmpty) {
          showCustomSnackBarWidget(getTranslated('shop_name_is_required', context), context, sanckBarType: SnackBarType.warning);
          return false;
        } else if (authController.shopAddressController.text.trim().isEmpty) {
          showCustomSnackBarWidget(getTranslated('shop_address_is_required', context), context, sanckBarType: SnackBarType.warning);
          return false;
        } else if (authController.shopLogo == null) {
          showCustomSnackBarWidget(getTranslated('shop_logo_is_required', context), context, sanckBarType: SnackBarType.warning);
          return false;
        }
        return true;

      case 3: // Tax info - optional, file-size guard happens on submit (see _handleSubmit)
        return true;
      default:
        return true;
    }
  }

  Future<void> _handleNext() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    if (_currentPage == _pageCount - 1) {
      await _handleSubmit(authController);
    } else if (_validateCurrentPage(authController)) {
      _goToPage(_currentPage + 1);
    }
  }

  Future<void> _handleSubmit(AuthController authController) async {
    final tinCertificateFile = Provider.of<ShopController>(Get.context!, listen: false).tinCertificateFile;
    if (tinCertificateFile != null && (await tinCertificateFile.length()) > (2 * 1024 * 1024)) {
      showCustomSnackBarWidget(getTranslated('single_file_size_can_not_be_more_than', Get.context!), Get.context!, sanckBarType: SnackBarType.warning);
      return;
    }

    RegisterModel registerModel = RegisterModel(
      fName: authController.firstNameController.text.trim(),
      lName: authController.lastNameController.text.trim(),
      phone: "${authController.countryDialCode}${authController.phoneController.text.trim()}",
      email: authController.emailController.text.trim(),
      password: authController.passwordController.text.trim(),
      confirmPassword: authController.confirmPasswordController.text.trim(),
      shopName: authController.shopNameController.text.trim(),
      shopAddress: authController.shopAddressController.text.trim(),
      businessTin: authController.tinNumberController.text.trim(),
      tinExpireDate: Provider.of<ShopController>(Get.context!, listen: false).tinExpireDate?.toString(),
    );
    authController.registration(Get.context!, registerModel, tinCertificateFile).then((value) {
      if (value.response!.statusCode == 200) {
        showCupertinoModalPopup(context: Get.context!, barrierDismissible: false, builder: (_) => const RegisterSuccessfulWidget());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        } else {
          _handleBack();
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(title: getTranslated('shop_application', context), isBackButtonExist: true, onBackPressed: _handleBack),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
            child: Column(children: [
              LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - (Dimensions.paddingSizeDefault * 2),
                lineHeight: 4.0,
                percent: (_currentPage + 1) / _pageCount,
                backgroundColor: Theme.of(context).hintColor.withValues(alpha: .3),
                progressColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('${getTranslated('step', context)} ${_currentPage + 1} ${getTranslated('of', context)} $_pageCount', style: Theme.of(context).textTheme.bodySmall),
              ),
            ]),
          ),
          Expanded(child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: _pages,
          )),
        ]),

        bottomNavigationBar: Consumer<AuthController>(
          builder: (context, authController, _) {
            if (authController.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              );
            }

            final isLastPage = _currentPage == _pageCount - 1;
            return Container(
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: Row(children: [
                if (_currentPage > 0) ...[
                  Expanded(
                    child: CustomButtonWidget(
                      btnTxt: getTranslated('back', context),
                      backgroundColor: Theme.of(context).hintColor,
                      isColor: true,
                      onTap: _handleBack,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                ],
                Expanded(
                  flex: 2,
                  child: CustomButtonWidget(
                    backgroundColor: (isLastPage && !(authController.isTermsAndCondition ?? false)) ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                    isColor: true,
                    btnTxt: getTranslated(isLastPage ? 'submit' : 'proceed_to_next', context),
                    onTap: (isLastPage && !(authController.isTermsAndCondition ?? false)) ? null : _handleNext,
                  ),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }
}
