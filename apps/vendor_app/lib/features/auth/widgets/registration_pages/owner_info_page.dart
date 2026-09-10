import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/registration_page_card.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/title_widget.dart';
import 'package:vendor_app/localization/language_constrants.dart';
import 'package:vendor_app/utill/dimensions.dart';
import 'package:vendor_app/utill/images.dart';
import 'package:vendor_app/utill/styles.dart';

class OwnerInfoPage extends StatelessWidget {
  const OwnerInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authProvider, _) {
        return RegistrationPageCard(
          heading: getTranslated('owner_info', context)!,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Column(children: [
                TitleWidget(title: getTranslated('first_name', context)!),
                CustomTextFieldWidget(
                  border: true,
                  hintText: getTranslated('first_name_hint', context),
                  focusNode: authProvider.firstNameNode,
                  nextNode: authProvider.lastNameNode,
                  textInputType: TextInputType.name,
                  controller: authProvider.firstNameController,
                  textInputAction: TextInputAction.next,
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Column(children: [
                TitleWidget(title: getTranslated('last_name', context)!),
                CustomTextFieldWidget(
                  border: true,
                  hintText: getTranslated('last_name_hint', context),
                  focusNode: authProvider.lastNameNode,
                  textInputType: TextInputType.name,
                  controller: authProvider.lastNameController,
                  textInputAction: TextInputAction.done,
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.04)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Align(alignment: Alignment.center, child:
                        DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            color: Theme.of(context).hintColor,
                            dashPattern: const [5, 5],
                            radius: const Radius.circular(Dimensions.paddingSizeSmall),
                          ),
                          child: Stack(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                              child: authProvider.sellerProfileImage != null ? Image.file(File(authProvider.sellerProfileImage!.path),
                                width: 150, height: 150, fit: BoxFit.cover,
                              ) : SizedBox(height: 150, width: 150,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Image.asset(Images.uploadImageIcon, scale: 3),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Text(getTranslated('upload_file', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor))
                                    ],
                                  ),
                                ),
                              )),
                              Positioned(bottom: 0, right: 0, top: 0, left: 0,
                                child: InkWell(
                                  onTap: () => authProvider.pickImage(true, false, false),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).hintColor.withValues(alpha: .08),
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          )),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(getTranslated('profile_image', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(getTranslated('image_ratio', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(getTranslated('image_size_2_mb', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
