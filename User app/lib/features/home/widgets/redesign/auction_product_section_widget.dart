import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/shimmers/auction_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/controllers/auction_home_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

AuctionCardState _cardState(AuctionProduct p) {
  return p.auctionDetails?.status == 'upcoming' ? AuctionCardState.upcoming : AuctionCardState.live;
}

DateTime _targetTime(AuctionProduct p) {
  final isLive = _cardState(p) == AuctionCardState.live;
  final raw = isLive ? p.auctionDetails?.endTime : p.auctionDetails?.startTime;
  return raw != null ? DateTime.tryParse(raw) ?? DateTime.now() : DateTime.now();
}

double _price(AuctionProduct p) {
  final isLive = _cardState(p) == AuctionCardState.live;
  if (isLive) {
    final highest = p.auctionDetails?.highestBidAmount;
    return (highest != null && highest != 0) ? highest.toDouble() : (p.startingPrice?.toDouble() ?? 0.0);
  }
  return p.startingPrice?.toDouble() ?? 0.0;
}

class AuctionProductSectionWidget extends StatefulWidget {
  final VoidCallback? onSeeAll;
  const AuctionProductSectionWidget({super.key, this.onSeeAll});

  @override
  State<AuctionProductSectionWidget> createState() => _AuctionProductSectionWidgetState();
}

class _AuctionProductSectionWidgetState extends State<AuctionProductSectionWidget> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuctionHomeController>(context, listen: false).getAuctionHomeSection(AuctionEnum.all);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.homePagePadding),
      padding: const EdgeInsets.only(top: 0),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomAssetImageWidget(
              Images.auctionProductsBg,
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
                child: AuctionSectionTitle(onSeeAll: widget.onSeeAll),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Selector<AuctionHomeController, List<AuctionProduct>?>(
                selector: (context, controller) {
                  final products = controller.allAuctionModel?.products;
                  return (products == null || products.isEmpty) ? null : products;
                },
                builder: (_, productList, __) {
                  if (productList == null) {
                    return const Center(child: _AuctionProductSectionShimmer());
                  }

                  return SizedBox(
                    height: ResponsiveHelper.isShortMobile(context) ? 240 : 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      itemCount: productList.length > AppConstants.auctionProductProductShowLimit ? AppConstants.auctionProductProductShowLimit : productList.length,
                      itemBuilder: (context, listIndex) {
                        final product = productList[listIndex];

                        return SizedBox(
                          width: 150,
                          child: AuctionCardWidget(
                            slug: product.slug ?? '',
                            state: _cardState(product),
                            imageUrl: product.thumbnailFullUrl?.path ?? '',
                            productName: product.name ?? '',
                            price: _price(product),
                            targetTime: _targetTime(product),
                            viewCount: product.auctionDetails?.totalViews ?? 0,
                            bidCount: product.auctionDetails?.totalBids,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuctionSectionTitle extends StatelessWidget {
  final VoidCallback? onSeeAll;
  const AuctionSectionTitle({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

      Row(children: [
        CustomAssetImageWidget(Images.gavelIcon, height: Dimensions.iconSizeDefault),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        Text(getTranslated('auction_products', context)!, style: titilliumBold.copyWith(
          fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)
        ),
      ]),

      GestureDetector(
        onTap: () => onSeeAll?.call(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Row(mainAxisSize: MainAxisSize.min,
            children: [
              Text(getTranslated('explore', context)!,
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Icon(Icons.arrow_forward_rounded, size: Dimensions.iconSizeSmall, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    ]);
  }
}

class _AuctionProductSectionShimmer extends StatelessWidget {
  const _AuctionProductSectionShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isShortMobile(context) ? 240 : 260,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
          itemCount: AppConstants.auctionProductProductShowLimit,
          separatorBuilder: (_, __) =>
          const SizedBox(width: Dimensions.paddingSizeDefault),
          itemBuilder: (_, __) => const SizedBox(
            width: 150,
            child: AuctionCardShimmerWidget(),
          ),
        ),
      ),
    );
  }
}