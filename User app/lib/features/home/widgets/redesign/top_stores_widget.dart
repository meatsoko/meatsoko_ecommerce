import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/store_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/store_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/home_title_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TopStoresWidget extends StatelessWidget {
  const TopStoresWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
        child: HomeTitleWidget(title: getTranslated('top_stores', context)!,
            onViewAllTap: () => RouterHelper.getAllTopSellerRoute(action: RouteAction.push, title: 'top_seller')),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Consumer<ShopController>(
        builder: (context, shopController, _) {
          final sellers = shopController.topSellerModel?.sellers;

          if (sellers == null) {
            return const _TopStoresShimmer();
          }

          if (sellers.isEmpty) {
            return const SizedBox();
          }

          return SizedBox(
            height: !ResponsiveHelper.isShortMobile(context) ? 160 : 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
              itemCount: sellers.length,
              separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) => StoreCardWidget(sellerInfo: sellers[index]),
            ),
          );
        },
      ),
      const SizedBox(height: Dimensions.homePagePadding),
    ]);
  }
}

class _TopStoresShimmer extends StatelessWidget {
  const _TopStoresShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: !ResponsiveHelper.isShortMobile(context) ? 160 : 150,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
          itemCount: 5,
          separatorBuilder: (_, __) =>
          const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (_, __) => const StoreCardShimmerWidget(),
        ),
      ),
    );
  }
}

