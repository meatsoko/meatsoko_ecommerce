import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/common/basewidgets/textfeild/custom_pass_textfeild_widget.dart';
import 'package:vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:vendor_app/features/auth/widgets/code_picker_widget.dart';
import 'package:vendor_app/features/auth/widgets/pass_view.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/registration_page_card.dart';
import 'package:vendor_app/localization/language_constrants.dart';
import 'package:vendor_app/utill/dimensions.dart';
import 'package:vendor_app/utill/styles.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();
    final authController = Provider.of<AuthController>(context, listen: false);
    _countryDialCode = authController.countryDialCode;
    authController.validPassCheck(authController.passwordController.text, isUpdate: false);
    if (authController.passwordController.text.isEmpty && authController.showPassView) {
      authController.showHidePass(isUpdate: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authProvider, _) {
        return RegistrationPageCard(
          heading: getTranslated('account_info', context)!,
          children: [
            Container(
              margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(getTranslated('email', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('email_hint', context),
                    focusNode: authProvider.emailNode,
                    nextNode: authProvider.phoneNode,
                    textInputType: TextInputType.emailAddress,
                    controller: authProvider.emailController,
                    textInputAction: TextInputAction.next,
                  )
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
              child: Text(getTranslated('phone', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha: .35)),
                color: Theme.of(context).highlightColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
              child: Row(children: [
                CodePickerWidget(
                  onChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                    authProvider.setCountryDialCode(_countryDialCode);
                  },
                  initialSelection: _countryDialCode,
                  favorite: [authProvider.countryDialCode!],
                  showDropDownButton: true,
                  padding: EdgeInsets.zero,
                  showFlagMain: true,
                  textStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),
                  dialogTextStyle: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                Expanded(child: CustomTextFieldWidget(
                  hintText: getTranslated('mobile_hint', context),
                  controller: authProvider.phoneController,
                  focusNode: authProvider.phoneNode,
                  nextNode: authProvider.passwordNode,
                  isPhoneNumber: true,
                  border: false,
                  focusBorder: false,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.phone,
                )),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeMedium),

            Container(margin: EdgeInsets.only(left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall, bottom: authProvider.showPassView ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(getTranslated('new_password', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: Dimensions.paddingSizeMedium),
                  CustomPasswordTextFieldWidget(
                    border: true,
                    hintTxt: getTranslated('enter_your_password', context),
                    textInputAction: TextInputAction.next,
                    focusNode: authProvider.passwordNode,
                    nextNode: authProvider.confirmPasswordNode,
                    controller: authProvider.passwordController,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!authProvider.showPassView) {
                          authProvider.showHidePass();
                        }
                        authProvider.validPassCheck(value);
                      } else {
                        if (authProvider.showPassView) {
                          authProvider.showHidePass();
                        }
                      }
                    },
                  )
                ],
              ),
            ),

            authProvider.showPassView ? const Padding(
              padding: EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
              child: PassView()) : const SizedBox(),
            authProvider.showPassView ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

            Container(margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(getTranslated('confirm_password', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: Dimensions.paddingSizeMedium),
                CustomPasswordTextFieldWidget(
                  border: true,
                  hintTxt: getTranslated('confirm_password', context),
                  textInputAction: TextInputAction.done,
                  focusNode: authProvider.confirmPasswordNode,
                  controller: authProvider.confirmPasswordController,
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}
