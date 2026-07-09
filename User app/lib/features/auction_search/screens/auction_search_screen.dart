import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_filter_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/shimmers/auction_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/controllers/auction_search_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/domain/models/auction_filter_param_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/widgets/auction_search_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AuctionSearchScreen extends StatefulWidget {
  const AuctionSearchScreen({super.key});

  @override
  State<AuctionSearchScreen> createState() => _AuctionSearchScreenState();
}

class _AuctionSearchScreenState extends State<AuctionSearchScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  AuctionFilterParamModel? _currentFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<AuctionSearchController>(context, listen: false);
      controller.loadSavedSearchNames();
      controller.getAuctionPopularTags();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    final controller = Provider.of<AuctionSearchController>(context, listen: false);
    if (controller.auctionListModel != null) {
      controller.cleanAuctionSearch(notify: true);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AuctionSearchAppBar(
          onBackPressed: _handleBack,
        ),
        body: Consumer<AuctionSearchController>(
          builder: (context, controller, child) {
            if (controller.searchText.isEmpty) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.only(top: 10),
                child: _buildDefaultUI(context),
              );
            }
            return AuctionSearchResultWidget(
              controller: controller,
              scrollController: scrollController,
              onFilterTap: () async {
                final filter = await AuctionFilterBottomSheet.show(context, currentFilter: _currentFilter);
                if (filter != null && context.mounted) {
                  final hasActiveFilters = filter.activeFilterCount > 0;
                  setState(() => _currentFilter = hasActiveFilters ? filter : null);
                  if (hasActiveFilters) {
                    controller.applyFilter(filter);
                  } else {
                    controller.clearFilter();
                  }
                  await controller.getAuctionList(offset: 1, search: controller.searchText, reload: true);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultUI(BuildContext context) {
    final controller = Provider.of<AuctionSearchController>(context, listen: false);

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.savedSearchNames.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(getTranslated('search_history', context) ?? '',
                        style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.clearSavedSearchNames(),
                      child: Text(getTranslated('clear_all', context) ?? '',
                        style: textRegular.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),

              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                children: [
                  for (int index = 0; index < controller.savedSearchNames.length; index++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeOverLarge)),
                          color: Provider.of<ThemeController>(context, listen: false).darkTheme
                              ? Colors.grey.withValues(alpha: 0.2) : Theme.of(context).colorScheme.onPrimary.withValues(alpha: .1),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall - 3,
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () {
                            controller.setSearchText(controller.savedSearchNames[index]);
                            controller.getAuctionList(search: controller.savedSearchNames[index], offset: 1, reload: true);
                          },
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                            child: Row(mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    controller.savedSearchNames[index],
                                    style: textRegular.copyWith(
                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                InkWell(
                                  onTap: () => controller.removeSearchName(index),
                                  child: SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                      Images.cancel,
                                      color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        if(controller.savedSearchNames.isNotEmpty)
          SizedBox(height: Dimensions.paddingSizeSmall),


        Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.homePagePadding,
            right: Dimensions.homePagePadding,
            bottom: Dimensions.paddingSizeSmall,
          ),
          child: Text(getTranslated("popular_tag", context) ?? "", style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Consumer<AuctionSearchController>(
            builder: (context, auctionController, _) {
              if (auctionController.isPopularTagsLoading) {
                return const _PopularTagsShimmer();
              }

              final tags = auctionController.popularTagModel?.popularTags ?? [];

              if (tags.isEmpty) return const SizedBox.shrink();

              return Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                children: [
                  for (int index = 0; index < tags.length; index++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: .5, color: Theme.of(context).hintColor),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall - 3,
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () {
                            final tag = tags[index].tag;
                            auctionController.searchFocusNode.unfocus();
                            auctionController.setSearchText(tag);
                            auctionController.saveSearchName(tag);
                            auctionController.getAuctionList(search: tag, offset: 1, reload: true);
                          },
                          child: ConstrainedBox(constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                            child: Text(tags[index].tag,
                              style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class AuctionSearchResultWidget extends StatelessWidget {
  final AuctionSearchController controller;
  final ScrollController scrollController;
  final VoidCallback onFilterTap;

  const AuctionSearchResultWidget({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<AuctionProduct> products = controller.auctionListModel?.products ?? [];

    if (controller.isAuctionListLoading && products.isEmpty) {
      return Padding(padding: const EdgeInsets.only(top: 15),
        child: _AuctionSearchResultShimmer(height: MediaQuery.of(context).size.height * 0.7));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.homePagePadding,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${controller.auctionListModel?.totalSize ?? products.length} Products Found',
                style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              if (products.isNotEmpty || controller.isFilterApplied)
                InkWell(
                  onTap: onFilterTap,
                  child: Stack(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomAssetImageWidget(Images.filterIcon, width: 20, height: 20,
                        color:  Provider.of<ThemeController>(context, listen: false).darkTheme?
                        Colors.white:Theme.of(context).primaryColor,
                      )
                    ),
                    if (controller.isFilterApplied)
                      CircleAvatar(radius: 5, backgroundColor: Theme.of(context).primaryColor),
                  ]),
                ),
            ],
          ),
        ),

        Expanded(
          child: products.isEmpty
            ? Center(
                child: NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_data_found', context) ?? ''),
              )
            : SingleChildScrollView(
              controller: scrollController,
              child: PaginatedListView(
                scrollController: scrollController,
                totalSize: controller.auctionListModel?.totalSize,
                offset: controller.auctionListModel?.offset,
                onPaginate: (offset) async {
                  await controller.getAuctionList(
                    search: controller.searchText,
                    offset: offset ?? 1,
                  );
                },
                itemView: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(Dimensions.homePagePadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    final isLive = item.auctionDetails?.status == 'live';

                  return AuctionCardWidget(
                    slug: item.slug ?? '',
                    state: isLive ? AuctionCardState.live : AuctionCardState.upcoming,
                    imageUrl: item.thumbnailFullUrl?.path ?? '',
                    productName: item.name ?? '',
                    price: (isLive ? item.auctionDetails?.highestBidAmount : item.startingPrice)?.toDouble() ?? 0,
                    targetTime: DateTime.tryParse(
                        isLive ? item.auctionDetails?.endTime ?? '' : item.auctionDetails?.startTime ?? '') ?? DateTime.now(),
                    viewCount: item.auctionDetails?.totalViews ?? 0,
                    bidCount: item.auctionDetails?.totalBids,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularTagsShimmer extends StatelessWidget {
  const _PopularTagsShimmer();

  static const List<double> _tagWidths = [60, 90, 70, 110, 50, 80, 100, 65];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color shimmerColor = isDark ? Theme.of(context).primaryColor.withValues(alpha: .05) : Theme.of(context).cardColor;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        children: _tagWidths.map((width) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Container(
              width: width,
              height: 30,
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AuctionSearchResultShimmer extends StatelessWidget {
  final double height;

  const _AuctionSearchResultShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color shimmerColor = isDark ? Theme.of(context).primaryColor.withValues(alpha: .05) : Theme.of(context).cardColor;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: SizedBox(
        height: height,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            // Product grid
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: Dimensions.paddingSizeSmall,
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                  childAspectRatio: 0.65,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const AuctionCardShimmerWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}