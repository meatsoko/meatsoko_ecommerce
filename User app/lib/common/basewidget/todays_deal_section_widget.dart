import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/recommended_product_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class TodaysDealSectionWidget extends StatelessWidget {
  const TodaysDealSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, _) {
        if (productController.recommendedProduct == null) {
          return const Padding(
            padding: EdgeInsets.only(bottom: Dimensions.homePagePadding),
            child: RecommendedProductShimmer(),
          );
        }

        if (productController.recommendedProduct?.id == -1) {
          return const SizedBox();
        }
        final product = productController.recommendedProduct!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double padding = Dimensions.paddingSizeDefault * 2;
            final double spacing = Dimensions.paddingSizeTwelve;
            final double bannerWidth = constraints.maxWidth * 0.3;

            final double cardWidth = constraints.maxWidth - padding - bannerWidth - spacing;
            final double infoPadding = Dimensions.paddingSizeSmall * 2;
            final double infoContentHeight = Dimensions.fontSizeExtraSmall + Dimensions.paddingSizeExtraExtraSmall + Dimensions.fontSizeSmall + Dimensions.paddingSizeExtraExtraSmall;

            final double bannerHeight = cardWidth + infoPadding + infoContentHeight;

            return Container(
              margin: const EdgeInsets.only(
                left: Dimensions.homePagePadding,
                right: Dimensions.homePagePadding,
                bottom: Dimensions.homePagePadding,
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: bannerWidth, height: bannerHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomAssetImageWidget(Images.todaysDealBanner, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeTwelve),

                  Expanded(
                    child: TodaysDealCard(
                      product: product,
                      onAddTap: () => RouterHelper.getProductDetailsRoute(action: RouteAction.push, productId: product.id, slug: product.slug),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TodaysDealCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddTap;

  const TodaysDealCard({super.key, required this.product, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final double rating = (product.rating?.isNotEmpty ?? false) ? double.tryParse('${product.rating?[0].average}') ?? 0 : 0;
    final int reviewCount = product.reviewCount ?? 0;
    final double discount = (product.clearanceSale?.discountAmount ?? product.discount) ?? 0;
    final String? discountType = (product.clearanceSale?.discountAmount ?? 0) > 0 ? product.clearanceSale?.discountType ?? 'amount' : product.discountType;
    final String productPrice = PriceConverter.convertPrice(context, product.unitPrice ?? 0, discount: discount, discountType: discountType);
    final bool hasDiscount = discount > 0;
    final String? originalPrice = hasDiscount ? PriceConverter.convertPrice(context, product.unitPrice) : null;

    return GestureDetector(
      onTap: () => RouterHelper.getProductDetailsRoute(
        action: RouteAction.push,
        productId: product.id,
        slug: product.slug,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double imageSize = constraints.maxWidth;
                  return ClipRRect(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(Dimensions.radiusDefault)),
                    child: CustomImageWidget(
                      image: product.thumbnailFullUrl?.path ?? '',
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              Positioned(
                bottom: Dimensions.paddingSizeExtraSmall,
                right: Dimensions.paddingSizeExtraSmall,
                child: FavouriteButtonWidget(
                  productId: product.id,
                  backgroundColor: Provider.of<ThemeController>(context).darkTheme ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rating > 0 && reviewCount > 0)
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: Dimensions.iconSizeExtraSmall, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                      Text('${rating.toStringAsFixed(1)} ($reviewCount ${getTranslated('review', context)!})',
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const Spacer(),
                      if ((product.currentStock ?? 0) > 0)
                        Row(
                          children: [
                            CustomAssetImageWidget(
                              Images.productCount,
                              width: Dimensions.fontSizeExtraSmall,
                              height: Dimensions.fontSizeExtraSmall,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                            Text('${product.currentStock} ${getTranslated('item_left', context)!}',
                              style: titilliumSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                Text(product.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                Row(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(productPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titilliumBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (hasDiscount && originalPrice != null)
                            Row(
                              children: [
                                Text('\$$originalPrice',
                                  style: titilliumRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme.of(context).hintColor,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Theme.of(context).hintColor,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeExtraSmall,
                                    vertical: Dimensions.paddingSizeExtraExtraSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error.withValues(alpha: .1),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.error.withValues(alpha: .5),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: Text('-${discountType == 'percent' || discountType == 'percentage' ? '${discount.toStringAsFixed(0)}%' : PriceConverter.convertPriceWithoutSymbol(context, discount)}',
                                    style: titilliumBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: onAddTap,
                      child: Container(width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: Dimensions.iconSizeDefault),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}