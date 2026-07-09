import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/controllers/auction_home_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/recently_viewed_auction_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

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

class ViewAllAuctionProductScreen extends StatefulWidget {
  final bool isFromRecentlyViewedSection;
  final AuctionEnum auctionEnum;
  final int? ownerId;
  final int? categoryId;
  final String? ownerName;
  const ViewAllAuctionProductScreen({super.key, required this.auctionEnum, this.isFromRecentlyViewedSection = false, this.ownerId, this.categoryId, this.ownerName});

  @override
  State<ViewAllAuctionProductScreen> createState() => _ViewAllAuctionProductScreenState();
}

class _ViewAllAuctionProductScreenState extends State<ViewAllAuctionProductScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.isFromRecentlyViewedSection) {
      Provider.of<AuctionHomeController>(context, listen: false)
          .getRecentlyViewedAuctionList(isLoggedIn: true);
    }
    Provider.of<AuctionHomeController>(context, listen: false)
        .getAuctionHomeSection(
      widget.auctionEnum,
      categoryId: widget.categoryId,
      ownerId: widget.ownerId,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  AuctionProductListModel? _getAuctionModel(AuctionHomeController controller) {
    if (widget.isFromRecentlyViewedSection) return null;
    switch (widget.auctionEnum) {
      case AuctionEnum.all:
        return controller.allAuctionModel;
      case AuctionEnum.endingSoon:
        return controller.endingSoonModel;
      case AuctionEnum.trending:
        return controller.trendingModel;
      case AuctionEnum.live:
        return controller.liveModel;
      case AuctionEnum.upcoming:
        return controller.upcomingModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<ThemeController>(context).darkTheme;

    return Scaffold(
      backgroundColor: isDarkTheme ? Theme.of(context).scaffoldBackgroundColor : null,
      appBar: CustomAppBar(title: _buildTitle(context)),

      body: Consumer<AuctionHomeController>(
        builder: (context, controller, child) {

          if (widget.isFromRecentlyViewedSection) {
            final recentlyViewedModel = controller.recentlyViewedModel;

            if (recentlyViewedModel == null) {
              return const ProductShimmer(isHomePage: false, isEnabled: true);
            }

            final items = recentlyViewedModel.recentViews ?? [];

            if (items.isEmpty) {
              return const NoInternetOrDataScreenWidget(isNoInternet: false);
            }

            return PaginatedListView(
              scrollController: _scrollController,
              totalSize: recentlyViewedModel.totalSize,
              offset: recentlyViewedModel.offset,
              onPaginate: (int? offset) async {
                await controller.getAuctionHomeSection(
                  widget.auctionEnum,
                  offset: offset ?? 1,
                  categoryId: widget.categoryId,
                  ownerId: widget.ownerId,
                );
              },
              itemView: Expanded(
                child: MasonryGridView.count(
                  crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final RecentlyViewedProduct? product = items[index].auctionProduct;
                    if (product == null) return const SizedBox.shrink();

                    final details = product.auctionDetails;
                    final bool isLive = details?.status != 'upcoming';

                    final AuctionCardState cardState = isLive ? AuctionCardState.live : AuctionCardState.upcoming;

                    final double price = isLive
                        ? ((details?.highestBidAmount != null && details!.highestBidAmount != 0)
                        ? details.highestBidAmount!.toDouble()
                        : product.startingPrice?.toDouble() ?? 0.0)
                        : product.startingPrice?.toDouble() ?? 0.0;

                    final String? rawTime = isLive ? details?.endTime : details?.startTime;
                    final DateTime targetTime = rawTime != null
                        ? DateTime.tryParse(rawTime) ?? DateTime.now() : DateTime.now();

                    return Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                      child: AuctionCardWidget(
                        slug: product.slug ?? '',
                        state: cardState,
                        imageUrl: product.thumbnailFullUrl?.path ?? '',
                        productName: product.name ?? '',
                        price: price,
                        targetTime: targetTime,
                        viewCount: details?.totalViews ?? 0,
                        bidCount: details?.totalBids,
                      ),
                    );
                  },
                ),
              ),
            );
          }

          final auctionModel = _getAuctionModel(controller);
          final auctionProducts = auctionModel?.products ?? [];

          if (auctionModel == null) {
            return const ProductShimmer(isHomePage: false, isEnabled: true);
          }

          if (auctionProducts.isEmpty) {
            return const NoInternetOrDataScreenWidget(isNoInternet: false);
          }

          return Padding(
            padding: const EdgeInsets.all(Dimensions.homePagePadding - Dimensions.paddingSizeExtraSmall),
            child: PaginatedListView(
              scrollController: _scrollController,
              totalSize: auctionModel.totalSize,
              offset: auctionModel.offset,
              onPaginate: (int? offset) async {
                await controller.getAuctionHomeSection(widget.auctionEnum, offset: offset ?? 1);
              },
              itemView: Expanded(
                child: MasonryGridView.count(
                  crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
                  itemCount: auctionProducts.length,
                  itemBuilder: (context, index) {
                    final product = auctionProducts[index];
                    return Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
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
              ),
            ),
          );
        },
      ),
    );
  }

  String _buildTitle(BuildContext context) {
    if (widget.isFromRecentlyViewedSection) return getTranslated('recently_viewed', context) ?? '';
    if (widget.categoryId != null) return getTranslated('similar_auction_product', context) ?? '';
    if (widget.ownerId != null) {
      final prefix = getTranslated('more_auction_from', context) ?? 'More Auction from';
      final name = widget.ownerName?.trim() ?? '';
      return name.isNotEmpty ? '$prefix $name' : prefix;
    }

    switch (widget.auctionEnum) {
      case AuctionEnum.endingSoon:
        return getTranslated('ending_soon', context) ?? '';
      case AuctionEnum.trending:
        return getTranslated('trending_auction_product', context) ?? '';
      case AuctionEnum.upcoming:
        return getTranslated('upcoming_auction_product', context) ?? '';
      default:
        return getTranslated('all_auction_product', context) ?? '';
    }
  }
}
