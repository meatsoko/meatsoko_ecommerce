import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/home_title_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedProductsWidget extends StatelessWidget {
  const FeaturedProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductModel?>(
      selector: (_, controller) => controller.featuredProductModel,
      builder: (_, featuredProductModel, __) {
        final products = featuredProductModel?.products;

        if (featuredProductModel == null) {
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
              child: HomeTitleWidget(
                title: getTranslated('featured_products', context)!,
                onViewAllTap: () => RouterHelper.getViewAllProductScreenRoute(productType: ProductType.featuredProduct, action: RouteAction.push),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            const _FeaturedProductsShimmer(),
            const SizedBox(height: Dimensions.homePagePadding),
          ]);
        }

        if (products == null || products.isEmpty) return const SizedBox.shrink();

        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
            child: HomeTitleWidget(
              title: getTranslated('featured_products', context)!,
              onViewAllTap: () => RouterHelper.getViewAllProductScreenRoute(productType: ProductType.featuredProduct, action: RouteAction.push),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(
            height: MediaQuery.sizeOf(context).shortestSide * 0.65,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
              separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
              itemCount: min(products.length, 4),
              itemBuilder: (context, index) => SizedBox(
                width: 150,
                child: ProductCardWidget(product: products[index]),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.homePagePadding),
        ]);
      },
    );
  }
}

class _FeaturedProductsShimmer extends StatelessWidget {
  const _FeaturedProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: !ResponsiveHelper.isShortMobile(Get.context!) ? 245 : 235,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
          itemCount: 4,
          separatorBuilder: (_, __) =>
          const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (_, __) => const SizedBox(
            width: 150,
            child: ProductCardShimmerWidget(),
          ),
        ),
      ),
    );
  }
}