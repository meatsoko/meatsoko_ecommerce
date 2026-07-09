import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/models/seller_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/shop_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class StoreCardWidget extends StatelessWidget {
  final Seller sellerInfo;

  const StoreCardWidget({super.key, required this.sellerInfo});

  @override
  Widget build(BuildContext context) {

   final bool vacationIsOn = ShopHelper.isVacationActive(
      context,
      startDate: sellerInfo.shop?.vacationStartDate,
      endDate: sellerInfo.shop?.vacationEndDate,
      vacationDurationType: sellerInfo.shop?.vacationDurationType,
      vacationStatus: sellerInfo.shop?.vacationStatus,
      isInHouseSeller: sellerInfo.id == 0,
    );

   final bool isTemporaryClosed = sellerInfo.shop?.temporaryClose ?? false;
   final bool showOverlay = isTemporaryClosed || vacationIsOn;

    return InkWell(
      onTap: () {
        RouterHelper.getTopSellerRoute (
          action: RouteAction.push,
          slug: sellerInfo.shop?.slug,
          sellerId: sellerInfo.id,
          temporaryClose: sellerInfo.shop?.temporaryClose,
          vacationStatus: sellerInfo.shop?.vacationStatus??false,
          vacationEndDate: sellerInfo.shop?.vacationEndDate,
          vacationStartDate: sellerInfo.shop?.vacationStartDate,
          vacationDurationType: sellerInfo.shop?.vacationDurationType,
          name: sellerInfo.shop?.name,
          banner: sellerInfo.shop?.bannerFullUrl?.path,
          image: sellerInfo.shop?.imageFullUrl?.path,
          totalProduct: sellerInfo.productCount,
          totalReview: sellerInfo.ratingCount,
          rating: sellerInfo.averageRating?.toString(),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: Theme.of(context).cardColor,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusSmall),
              topRight: Radius.circular(Dimensions.radiusSmall),
            ),
            child: CustomImageWidget(image: sellerInfo.shop?.bannerFullUrl?.path ?? '', fit: BoxFit.cover, height: 70),
          ),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            color: Theme.of(context).cardColor,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImageWidget(
                        image: sellerInfo.shop?.imageFullUrl?.path ?? '',
                        height: 40, width: 40, fit: BoxFit.cover),
                    ),

                    if (showOverlay)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: Container(
                          width: 40, height: 40, color: Colors.black.withValues(alpha: .5)),
                      ),

                    if (showOverlay)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Text(
                            isTemporaryClosed ? getTranslated('temporary_closed', context)! : getTranslated('close_for_now', context)!,
                            textAlign: TextAlign.center,
                            style: textRegular.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sellerInfo.shop?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),

                    Row(children: [
                      Icon(Icons.star,
                        color: Theme.of(context).colorScheme.secondary,
                        size: Dimensions.iconSizeExtraSmall,
                      ),

                      Text(sellerInfo.averageRating.toString(),
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ]),
                  ]),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Divider(height: 1, color: Theme.of(context).hintColor),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Row(children: [
                  CustomAssetImageWidget(Images.productCount, height: 12),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text('${sellerInfo.productCount} ${getTranslated('products', context)}',
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ]),

                Text('${sellerInfo.reviewCount ?? 0} ${getTranslated('review', context)!}',
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}