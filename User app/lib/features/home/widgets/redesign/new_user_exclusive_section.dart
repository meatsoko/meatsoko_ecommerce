import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/home_title_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NewUserExclusiveSection extends StatelessWidget {
  const NewUserExclusiveSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (_, productController, ___) {
        final products = productController.justForYouProductModel?.products;

        // Hide the entire section (title included) when there are no products.
        if (products != null && products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
            child: HomeTitleWidget(title: getTranslated('new_user_exclusive', context) ?? '',
              onViewAllTap: () => RouterHelper.getViewAllProductScreenRoute(productType: ProductType.justForYou, action: RouteAction.push)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          if (products == null)
            const _NewUserExclusiveSectionShimmer()
          else
            SizedBox(
              height: MediaQuery.sizeOf(context).shortestSide * 0.65,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
                separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
                itemCount: products.length,
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

class _NewUserExclusiveSectionShimmer extends StatelessWidget {
  const _NewUserExclusiveSectionShimmer();

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