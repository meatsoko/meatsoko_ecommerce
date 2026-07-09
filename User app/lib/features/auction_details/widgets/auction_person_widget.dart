import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionPersonWidget extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback? onMessageTap;
  final VoidCallback? onTap;
  final bool showChatIcon;
  final bool isOwner;

  const AuctionPersonWidget({
    super.key,
    required this.name,
    this.avatarUrl,
    this.onMessageTap,
    this.onTap,
    this.showChatIcon = true,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.homePagePadding,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        children: [
          ClipOval(child: CustomImageWidget(image: avatarUrl ?? '', placeholder: Images.user, height: Dimensions.iconSizeExtraLarge)),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      if (isOwner)
                        TextSpan(
                          text: ' (${getTranslated('you', context) ?? ""})',
                          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                Text(getTranslated('auction_seller', context) ?? "",
                  style: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),

          if (showChatIcon)
            GestureDetector(
              onTap: onMessageTap,
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  // borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  // border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15), width: 2),
                ),
                child: CustomAssetImageWidget(Images.auctionChatIcon),
              ),
            ),
        ],
      ),
    ),
    );
  }
}