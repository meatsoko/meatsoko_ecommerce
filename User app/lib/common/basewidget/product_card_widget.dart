import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/models/shop_navigation_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final bool isBestSelling;
  final bool isNew;
  final SellerNavigationModel? sellerNavigationModel;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.isBestSelling = false,
    this.isNew = false,
    this.sellerNavigationModel,
  });

  @override
  Widget build(BuildContext context) {
    final double rating = (product.rating?.isNotEmpty ?? false) ? double.tryParse('${product.rating?[0].average}') ?? 0 : 0;
    final int reviewCount = product.reviewCount ?? 0;
    final double discount = (product.clearanceSale?.discountAmount ?? product.discount) ?? 0;
    final String? discountType = (product.clearanceSale?.discountAmount ?? 0) > 0 ? product.clearanceSale?.discountType ?? 'amount' : product.discountType;
    final String productPrice = PriceConverter.convertPrice(context, product.unitPrice ?? 0, discount: discount, discountType: discountType);
    final bool hasDiscount = discount > 0;
    final String? originalPrice = hasDiscount ? PriceConverter.convertPrice(context, product.unitPrice) : null;
    // PriceConverter.convertPrice(context, product.unitPrice)

    return InkWell(
          onTap: () => RouterHelper.getProductDetailsRoute(action: RouteAction.push, productId: product.id, slug: product.slug),
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                        child: CustomImageWidget(
                          width: double.infinity,
                          height: double.infinity,
                          image: product.thumbnailFullUrl?.path ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    if (product.currentStock == 0 && product.productType == 'physical') ...[
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(Dimensions.radiusSmall),
                                bottomLeft: Radius.circular(Dimensions.radiusSmall)
                            ),
                          ),
                          child: Text(
                            getTranslated('out_of_stock', context) ?? 'Out of Stock',
                            textAlign: TextAlign.center,
                            style: titilliumBold.copyWith(
                              color: Theme.of(context).cardColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (isBestSelling || isNew)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(Dimensions.radiusDefault),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                if (isBestSelling)
                                  CustomAssetImageWidget(Images.bestSellingTag, height: 15),
                                if (isNew && !isBestSelling)
                                  CustomAssetImageWidget(Images.newTag, height: 15),
                              ],
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      bottom: Dimensions.paddingSizeExtraSmall,
                      right: Dimensions.paddingSizeExtraSmall,
                      child: FavouriteButtonWidget(
                        sellerNavigationModel: sellerNavigationModel,
                        productId: product.id,
                        backgroundColor:
                        Provider.of<ThemeController>(context, listen: false).darkTheme ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(product.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                    if (rating > 0 && reviewCount > 0) ...[
                      Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.star, color: Theme.of(context).colorScheme.secondary, size: Dimensions.iconSizeExtraSmall),
                          Text(rating.toStringAsFixed(1),
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),

                          Expanded(
                            child: Text('($reviewCount ${getTranslated('review', context)!})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titilliumRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                    ],

                    Text(productPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),


                    if (hasDiscount && originalPrice != null)
                      Row(
                        children: [
                          Text(
                            originalPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),

                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                              borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall - 2),
                            child: Text('-${discountType == 'percent' || discountType == 'percentage' ? '${discount.toStringAsFixed(0)}%' : PriceConverter.convertPriceWithoutSymbol(context, discount)}',
                              style: titilliumBold.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
  }
}