import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/registration_page_card.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/title_widget.dart';
import 'package:vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:vendor_app/features/shop/screens/vacation_mode_setup_screen.dart';
import 'package:vendor_app/helper/date_converter.dart';
import 'package:vendor_app/localization/language_constrants.dart';
import 'package:vendor_app/utill/dimensions.dart';
import 'package:vendor_app/utill/images.dart';
import 'package:vendor_app/utill/styles.dart';

class TaxInfoPage extends StatelessWidget {
  const TaxInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authProvider, _) {
        return RegistrationPageCard(
          heading: getTranslated('tax_info', context)!,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Text('${getTranslated('optional', context)}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Consumer<ShopController>(
              builder: (context, shopController, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [
                      TitleWidget(title: getTranslated('taxpayer_identification_number', context)!, isRequired: false),
                      CustomTextFieldWidget(
                        border: true,
                        isDescription: true,
                        textInputType: TextInputType.text,
                        hintText: '${getTranslated('enter_tin_number', context)}',
                        controller: authProvider.tinNumberController,
                        showIconDecorationColor: false,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      TitledBorder(
                        title: getTranslated('expire_date', context) ?? '',
                        isRequired: false,
                        content: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  shopController.tinExpireDate != null ?
                                  DateConverter.stringToLocalDateOnly(shopController.tinExpireDate.toString()) :
                                  getTranslated('select_date', context) ?? '',
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await shopController.pickTinExpireDate(context);
                                },
                                child: CustomAssetImageWidget(Images.calender, width: 20, height: 20, color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Text(getTranslated('tin_certificate', context) ?? '',
                          style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(getTranslated('tin_file_size', context) ?? '',
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeDefault)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          dashPattern: const [4, 5],
                          color: shopController.tinCertificateFile != null ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                          radius: const Radius.circular(Dimensions.paddingEye),
                        ),
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Stack(
                            children: [
                              if (shopController.tinCertificateFile != null)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: InkWell(
                                    onTap: () {
                                      if (shopController.tinCertificateFile != null) {
                                        shopController.removeTinCertificateFile();
                                      }
                                    },
                                    child: shopController.isLoading ? const Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator())) : Image.asset(width: 25, Images.digitalPreviewDeleteIcon),
                                  ),
                                ),
                              Positioned.fill(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (shopController.tinCertificateFile == null)
                                        ...[
                                          InkWell(
                                            onTap: () => shopController.pickTinCertificateFile(),
                                            child: Column(
                                              children: [
                                                SizedBox(width: 30, child: Image.asset(Images.uploadIcon)),
                                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                Text(
                                                    shopController.shopModel?.tinCertificateFullUrl != null ?
                                                    shopController.shopModel?.tinCertificateFullUrl?.key ?? ''
                                                        : getTranslated('upload_file', context)!,
                                                    style: robotoRegular.copyWith(fontWeight: FontWeight.w600, fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      if (shopController.tinCertificateFile != null)
                                        ...[
                                          Column(
                                            children: [
                                              SizedBox(width: 30, child: Image.asset(Images.digitalPreviewFileIcon)),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              Text(shopController.tinCertificateFile?.name ?? '',
                                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
