import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/custom_image_widget.dart';
import 'package:user_app/features/home/widgets/redesign/home_title_widget.dart';
import 'package:user_app/features/shop/controllers/shop_controller.dart';
import 'package:user_app/features/shop/domain/models/seller_model.dart';
import 'package:user_app/helper/responsive_helper.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/brand_colors.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

/// "Discover Near You" — a lighter-weight, image-forward companion to
/// [TopStoresWidget] (same ShopController data), styled after the reference
/// reskin: full-bleed shop banner with a floating rating badge, rather than
/// the fuller shop-info card used elsewhere.
class DiscoverNearYouWidget extends StatelessWidget {
  const DiscoverNearYouWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
        child: HomeTitleWidget(
          title: getTranslated('discover_near_you', context) ?? 'Discover Near You',
          onViewAllTap: () => RouterHelper.getAllTopSellerRoute(action: RouteAction.push, title: 'top_seller'),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Consumer<ShopController>(
        builder: (context, shopController, _) {
          final sellers = shopController.topSellerModel?.sellers;

          if (sellers == null) {
            return const _DiscoverShimmer();
          }

          if (sellers.isEmpty) {
            return const SizedBox();
          }

          // Two cards fill the row width, same as the reference (no partial
          // third card peeking in) — sized off the actual screen width
          // rather than a fixed guess.
          final double screenWidth = MediaQuery.of(context).size.width;
          final double cardWidth = (screenWidth - Dimensions.homePagePadding * 2 - Dimensions.paddingSizeSmall) / 2;

          return SizedBox(
            height: !ResponsiveHelper.isShortMobile(context) ? cardWidth * 1.05 : cardWidth * 0.95,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
              itemCount: sellers.length,
              separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) => _DiscoverCard(sellerInfo: sellers[index], width: cardWidth),
            ),
          );
        },
      ),
      const SizedBox(height: Dimensions.homePagePadding),
    ]);
  }
}

class _DiscoverCard extends StatelessWidget {
  final Seller sellerInfo;
  final double width;
  const _DiscoverCard({required this.sellerInfo, required this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      onTap: () {
        RouterHelper.getTopSellerRoute(
          action: RouteAction.push,
          slug: sellerInfo.shop?.slug,
          sellerId: sellerInfo.id,
          temporaryClose: sellerInfo.shop?.temporaryClose,
          vacationStatus: sellerInfo.shop?.vacationStatus ?? false,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: SizedBox(
          width: width,
          child: Stack(fit: StackFit.expand, children: [
            CustomImageWidget(image: sellerInfo.shop?.bannerFullUrl?.path ?? sellerInfo.shop?.imageFullUrl?.path ?? '', fit: BoxFit.cover),

            // Rating badge, bottom-left — matches the reference; no
            // shop-name overlay there, and no fabricated delivery-time
            // chip since the shop model has no such field.
            Positioned(
              left: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star, size: 12, color: BrandColors.ochre),
                  const SizedBox(width: 3),
                  Text(sellerInfo.averageRating?.toStringAsFixed(1) ?? '-',
                    style: textBold.copyWith(color: BrandColors.burgundyDark, fontSize: Dimensions.fontSizeExtraSmall),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _DiscoverShimmer extends StatelessWidget {
  const _DiscoverShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: !ResponsiveHelper.isShortMobile(context) ? 150 : 130,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(width: 170, color: Theme.of(context).cardColor),
          ),
        ),
      ),
    );
  }
}
