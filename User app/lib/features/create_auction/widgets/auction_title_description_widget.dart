import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/controllers/auction_ai_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


class AuctionTitleDescriptionWidget extends StatefulWidget {
  final List<TextEditingController> titleControllerList;
  final List<TextEditingController> descriptionControllerList;
  final int index;
  final String langCode;
  final bool isRequired;

  const AuctionTitleDescriptionWidget({
    super.key,
    required this.titleControllerList,
    required this.descriptionControllerList,
    required this.index,
    required this.langCode,
    this.isRequired = false,
  });

  @override
  State<AuctionTitleDescriptionWidget> createState() => _AuctionTitleDescriptionWidgetState();
}

class _AuctionTitleDescriptionWidgetState extends State<AuctionTitleDescriptionWidget> {
  @override
  Widget build(BuildContext context) {
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.iconSizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI button for title
          if (aiEnabled)
            Consumer<AuctionAiController>(
              builder: (context, aiController, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.titleControllerList[widget.index].text.isEmpty) {
                          showCustomSnackBarWidget(
                            getTranslated('product_name_required', context) ?? 'Product name is required',
                            context, snackBarType: SnackBarType.warning
                          );
                        } else {
                          aiController.generateAuctionTitle(
                            title: widget.titleControllerList[widget.index].text.trim(),
                            nameController: widget.titleControllerList[widget.index],
                            langCode: widget.langCode,
                          );
                        }
                      },
                      child: !aiController.titleLoading
                          ? Icon(Icons.auto_awesome, color: Colors.blue)
                          : Shimmer.fromColors(
                              baseColor: Theme.of(context).primaryColor,
                              highlightColor: Colors.grey[100]!,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.blue),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    getTranslated('generating', context) ?? 'Generating...',
                                    style: robotoBold.copyWith(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Title input field
          CustomTextFieldWidget(
            controller: widget.titleControllerList[widget.index],
            hintText: '${getTranslated('product_name', context) ?? 'Type Product Name'}${widget.isRequired ? ' *' : ''}',
            showBorder: true,
            borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
            hintTextStyle : titleRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // AI button for description
          if (aiEnabled)
            Consumer<AuctionAiController>(
              builder: (context, aiController, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.titleControllerList[widget.index].text.isEmpty) {
                          showCustomSnackBarWidget(
                            getTranslated('product_name_required', context) ?? 'Product name is required',
                            context, snackBarType: SnackBarType.warning
                          );
                        } else {
                          aiController.generateAuctionDescription(
                            title: widget.titleControllerList[widget.index].text.trim(),
                            descriptionController: widget.descriptionControllerList[widget.index],
                            langCode: widget.langCode,
                          );
                        }
                      },
                      child: !aiController.descLoading
                          ? Icon(Icons.auto_awesome, color: Colors.blue)
                          : Shimmer.fromColors(
                              baseColor: Theme.of(context).primaryColor,
                              highlightColor: Colors.grey[100]!,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.blue),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    getTranslated('generating', context) ?? 'Generating...',
                                    style: robotoBold.copyWith(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Description input field
          CustomTextFieldWidget(
            controller: widget.descriptionControllerList[widget.index],
            hintText: '${getTranslated('product_description', context) ?? 'Description'}${widget.isRequired ? ' *' : ''}',
            showBorder: true,
            borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
            maxLines: 3,
            hintTextStyle : titleRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}
