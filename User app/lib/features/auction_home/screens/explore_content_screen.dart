import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/shimmers/auction_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/shimmers/auction_horizontal_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/controllers/auction_category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/controllers/auction_home_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_horizontal_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ExploreContent extends StatelessWidget {
  final void Function(int categoryId)? onCategoryViewAll;

  const ExploreContent({super.key, this.onCategoryViewAll});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
    return Consumer<AuctionHomeController>(
      builder: (context, controller, _) {
        return SliverList(
          delegate: SliverChildListDelegate([
           // const SizedBox(height: Dimensions.paddingSizeDefault),
            EndingSoonSectionWidget(products: controller.endingSoonModel?.products),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            TrendingAuctionProductSectionWidget(products: controller.trendingModel?.products),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            if (isLoggedIn) ...[
              const RecentlyViewedSectionWidget(),
            ],

            UpcomingAuctionSectionWidget(products: controller.upcomingModel?.products),

            CategoryAuctionSectionWidget(onViewAll: onCategoryViewAll),

            SizedBox(height: Dimensions.paddingSizeDefault + MediaQuery.of(context).padding.bottom),
          ]),
        );
      },
    );
  }
}

AuctionCardState _cardState(AuctionProduct p) {
  final status = p.auctionDetails?.status;
  if (status == 'upcoming') return AuctionCardState.upcoming;
  if (status == 'live') return AuctionCardState.live;
  return AuctionCardState.ended;
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

AuctionCardWidget _buildCard(AuctionProduct p) {
  return AuctionCardWidget(
    slug: p.slug ?? '',
    state: _cardState(p),
    imageUrl: p.thumbnailFullUrl?.path ?? '',
    productName: p.name ?? '',
    price: _price(p),
    targetTime: _targetTime(p),
    viewCount: p.auctionDetails?.totalViews ?? 0,
    bidCount: p.auctionDetails?.totalBids,
  );
}


class EndingSoonSectionWidget extends StatelessWidget {
  final List<AuctionProduct>? products;

  const EndingSoonSectionWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products != null && products!.isEmpty) return const SizedBox.shrink();

    final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark ? [
            ColorHelper.blendColors(Theme.of(context).cardColor, Theme.of(context).colorScheme.secondary, 0.93),
            ColorHelper.blendColors(Theme.of(context).cardColor, Theme.of(context).colorScheme.primary, 0.96),
          ] : const [
            Color(0xFFFEF3E9),
            Color(0xFFF7F2FD),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.homePagePadding,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomAssetImageWidget(Images.auctionEndingSoonIcon),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      getTranslated('ending_soon', context)!,
                        style: titilliumBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => RouterHelper.getViewAllAuctionProductScreenRoute(auctionEnum: AuctionEnum.endingSoon),
                  child: Text(
                    getTranslated('view_all', context)!,
                    style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      )
                  ),
                ),
              ],
            ),
          ),

          if (products == null)
            _AuctionHorizontalListShimmer(height: 250)
          else
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  left: Dimensions.homePagePadding,
                  right: Dimensions.homePagePadding,
                  bottom: Dimensions.paddingSizeSmall,
                ),
                itemCount: products!.length,
                separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
                itemBuilder: (_, i) => SizedBox(width: 160, child: _buildCard(products![i])),
              ),
            ),
        ],
      ),
    );
  }
}

class TrendingAuctionProductSectionWidget extends StatelessWidget {
  final List<AuctionProduct>? products;

  const TrendingAuctionProductSectionWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products != null && products!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomAssetImageWidget(Images.auctionTrendingProductIcon),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    getTranslated('trending_auction_product', context)!,
                      style: titilliumBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      )
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => RouterHelper.getViewAllAuctionProductScreenRoute(auctionEnum: AuctionEnum.trending),
                child: Text(
                  getTranslated('view_all', context)!,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        if (products == null)
          const _AuctionHorizontalListShimmer(height: 250)
        else if (products!.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.homePagePadding,
                vertical: Dimensions.paddingSizeSmall,
              ),
              itemCount: products!.length,
              separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (_, i) => SizedBox(width: 160, child: _buildCard(products![i])),
            ),
          ),
      ],
    );
  }
}

class UpcomingAuctionSectionWidget extends StatelessWidget {
  final List<AuctionProduct>? products;

  const UpcomingAuctionSectionWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products != null && products!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getTranslated('upcoming_auction', context)!,
                  style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )
              ),
              GestureDetector(
                onTap: () => RouterHelper.getViewAllAuctionProductScreenRoute(auctionEnum: AuctionEnum.upcoming),
                child: Text(
                  getTranslated('view_all', context)!,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        if (products == null)
          const _AuctionHorizontalListShimmer(height: 250)
        else
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
              itemCount: products!.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (_, index) {
                if (index == 0) {
                  final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
                  return Container(
                    width: 75,
                    height: 230,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomAssetImageWidget(
                          Images.auctionComingSoonBanner,
                          width: 75,
                          height: 230,
                          fit: BoxFit.cover,
                        ),
                        if (isDark)
                          ColoredBox(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.25),
                          ),
                      ],
                    ),
                  );
                }
                return SizedBox(
                  width: 160,
                  child: _buildCard(products![index - 1]),
                );
              },
            ),
          ),
      ],
    );
  }
}

class RecentlyViewedSectionWidget extends StatelessWidget {
  const RecentlyViewedSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionHomeController>(
      builder: (context, controller, _) {
        final items = controller.recentlyViewedModel?.recentViews;

        if (items != null && items.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeEight, bottom: Dimensions.paddingSizeEight),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated('recently_viewed', context)!,
                        style: titilliumBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )
                    ),
                    GestureDetector(
                      onTap: () => RouterHelper.getViewAllAuctionProductScreenRoute(isFromRecentlyViewedSection: true),
                      child: Text(
                        getTranslated('view_all', context)!,
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (items == null) const _AuctionHorizontalCardListShimmer()

              else
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeExtraSmall,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
                    itemBuilder: (_, i) {
                      final product = items[i].auctionProduct;
                      final details = product?.auctionDetails;
                      final cardState = details?.status == 'live'
                          ? AuctionCardState.live
                          : details?.status == 'upcoming'
                              ? AuctionCardState.upcoming
                              : AuctionCardState.ended;
                      final isLive = cardState == AuctionCardState.live;
                      final raw = isLive ? details?.endTime : details?.startTime;
                      final targetTime = raw != null ? DateTime.tryParse(raw) ?? DateTime.now() : DateTime.now();
                      final highest = details?.highestBidAmount;
                      final price = isLive ? (highest != null && highest != 0 ? highest.toDouble() : (product?.startingPrice?.toDouble() ?? 0.0)) : (product?.startingPrice?.toDouble() ?? 0.0);

                      return SizedBox(
                        width: 280,
                        child: AuctionHorizontalCardWidget(
                          state: cardState,
                          slug: product?.slug ?? '',
                          imageUrl: product?.thumbnailFullUrl?.path ?? '',
                          productName: product?.name ?? '',
                          price: price,
                          targetTime: targetTime,
                          viewCount: details?.totalViews ?? 0,
                          bidCount: details?.totalBids,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryAuctionSectionWidget extends StatelessWidget {
  final void Function(int categoryId)? onViewAll;

  const CategoryAuctionSectionWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionCategoryController>(
      builder: (context, controller, _) {
        final categories = controller.categoryList;
        if (categories.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(categories.length, (index) {
            final category = categories[index];
            final categoryId = category.id!;
            final model = controller.categoryProductsFor(categoryId);
            final products = model?.products;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              category.name ?? '',
                                style: titilliumBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                )
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            if (category.auctionProductCount != null)
                              Text(
                                '(${category.auctionProductCount ?? 0} ${getTranslated('products', context)!})',
                                style: titilliumRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onViewAll?.call(category.id!),
                        child: Text(getTranslated('view_all', context)!,
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if (products == null) const _AuctionHorizontalCardListShimmer()

                else if (products.isEmpty) const SizedBox.shrink()

                else
                  SizedBox(
                    height: 85,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
                      itemCount: products.length > 5 ? 5 : products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
                      itemBuilder: (_, i) => SizedBox(
                        width: 270,
                        child: AuctionHorizontalCardWidget(
                          state: _cardState(products[i]),
                          slug: products[i].slug ?? '',
                          imageUrl: products[i].thumbnailFullUrl?.path ?? '',
                          productName: products[i].name ?? '',
                          price: _price(products[i]),
                          targetTime: _targetTime(products[i]),
                          viewCount: products[i].auctionDetails?.totalViews ?? 0,
                          bidCount: products[i].auctionDetails?.totalBids,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        );
      },
    );
  }
}

class _AuctionHorizontalListShimmer extends StatelessWidget {
  final double height;

  const _AuctionHorizontalListShimmer({this.height = 260});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          itemCount: 4,
          separatorBuilder: (_, __) =>
          const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (_, __) => const SizedBox(
            width: 160,
            child: AuctionCardShimmerWidget(),
          ),
        ),
      ),
    );
  }
}

class _AuctionHorizontalCardListShimmer extends StatelessWidget {
  const _AuctionHorizontalCardListShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          itemCount: 3,
          separatorBuilder: (_, __) =>
          const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (_, __) => const SizedBox(
            width: 280,
            child: AuctionHorizontalCardShimmerWidget(),
          ),
        ),
      ),
    );
  }
}