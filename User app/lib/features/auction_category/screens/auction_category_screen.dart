import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/shimmers/auction_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/controllers/auction_category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/controllers/auction_search_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/domain/models/auction_filter_param_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/domain/models/auction_category_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_filter_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AuctionCategoryScreen extends StatefulWidget {
  final bool isBacButtonExist;
  const AuctionCategoryScreen({super.key, this.isBacButtonExist = true});

  @override
  State<AuctionCategoryScreen> createState() => _AuctionCategoryScreenState();
}

class _AuctionCategoryScreenState extends State<AuctionCategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  AuctionFilterParamModel? _currentFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<AuctionCategoryController>(context, listen: false);
      controller.getCategoryList(false).then((_) {
        if (controller.categoryList.isNotEmpty) {
          final firstCategoryId = controller.categoryList[0].id!;
          controller.getCategoryProducts(firstCategoryId, 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('CATEGORY', context), isBackButtonExist: widget.isBacButtonExist),
      body: Consumer<AuctionCategoryController>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.categoryList.isEmpty) {
            return categoryProvider.isCategoryListLoading
              ? const _AuctionCategoryScreenShimmer()
              : Center(
                  child: NoInternetOrDataScreenWidget(
                    isNoInternet: false,
                    message: getTranslated('no_data_found', context) ?? '',
                  ),
                );
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: double.infinity,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: categoryProvider.categoryList.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      AuctionCategoryModel category = categoryProvider.categoryList[index];
                      return InkWell(
                        onTap: () {
                          categoryProvider.onChangeSelectedIndex(index);
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(0);
                          }
                          if (category.id != null) {
                            categoryProvider.getCategoryProducts(category.id!, 1);
                          }
                          setState(() => _currentFilter = null);
                        },
                        child: _CategoryItem(
                          title: category.name,
                          isSelected: categoryProvider.categorySelectedIndex == index,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: _buildProductPanel(categoryProvider),
                ),
              ),
            ]);
        },
      ),
    );
  }

  Widget _buildProductPanel(AuctionCategoryController categoryProvider) {
    final selectedIndex = categoryProvider.categorySelectedIndex ?? 0;

    if (selectedIndex >= categoryProvider.categoryList.length) {
      return const SizedBox();
    }

    final selectedCategory = categoryProvider.categoryList[selectedIndex];
    final categoryId = selectedCategory.id;

    if (categoryId == null) return const SizedBox();

    final productListModel = categoryProvider.categoryProductsFor(categoryId);

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: Dimensions.paddingSizeSmall,
          //     vertical: Dimensions.paddingSizeSmall,
          //   ),
          //   child: Text(selectedCategory.name ?? '',
          //     style: titilliumBold.copyWith(
          //       fontSize: Dimensions.fontSizeLarge,
          //       color: Theme.of(context).textTheme.bodyLarge?.color,
          //     ),
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
              Text(getTranslated('top_product', context) ?? '',
                  style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeDefault
                  )),

              InkWell(
                onTap: () async {
                  final searchController = Provider.of<AuctionSearchController>(context, listen: false);
                  final result = await AuctionFilterBottomSheet.show(
                    context,
                    isCategoryPage: true,
                    categoryId: categoryId,
                    currentFilter: _currentFilter,
                  );
                  if (result != null && context.mounted) {
                    setState(() => _currentFilter = result);
                    searchController.applyFilter(result);
                    await searchController.getAuctionList(offset: 1, reload: true);
                  }
                },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomAssetImageWidget(Images.filterIcon, width: 20, height: 20),
                  ))
            ]),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                if (_currentFilter != null) {
                  return _AuctionFilteredProductGrid(scrollController: _scrollController);
                }

                if (productListModel == null ||
                    productListModel.products == null) {
                  return const _AuctionProductPanelShimmer();
                }

                if (productListModel.products!.isEmpty) {
                  return Center(
                    child: NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_data_found', context) ?? ''));
                }

                return _AuctionProductGrid(
                  key: ValueKey(categoryId),
                  categoryId: categoryId,
                  scrollController: _scrollController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionFilteredProductGrid extends StatelessWidget {
  final ScrollController scrollController;

  const _AuctionFilteredProductGrid({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionSearchController>(
      builder: (context, searchController, _) {
        if (searchController.isAuctionListLoading) {
          return const _AuctionProductPanelShimmer();
        }

        final products = searchController.auctionListModel?.products ?? [];

        if (products.isEmpty) {
          return Center(
            child: NoInternetOrDataScreenWidget(
              isNoInternet: false,
              message: getTranslated('no_data_found', context) ?? '',
            ),
          );
        }

        return PaginatedListView(
          scrollController: scrollController,
          totalSize: searchController.auctionListModel?.totalSize,
          offset: searchController.auctionListModel?.offset,
          onPaginate: (int? offset) async {
            if (offset != null) {
              await searchController.getAuctionList(offset: offset);
            }
          },
          itemView: Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ).copyWith(bottom: MediaQuery.of(context).padding.bottom),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisSpacing: Dimensions.paddingSizeSmall,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _AuctionProductCard(product: products[index]);
              },
            ),
          ),
        );
      },
    );
  }
}

class _AuctionProductGrid extends StatelessWidget {
  final int categoryId;
  final ScrollController scrollController;

  const _AuctionProductGrid({
    super.key,
    required this.categoryId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionCategoryController>(
      builder: (context, categoryProvider, _) {
        final productListModel =
            categoryProvider.categoryProductsFor(categoryId);
        final products = productListModel?.products ?? [];

        return PaginatedListView(
          scrollController: scrollController,
          totalSize: productListModel?.totalSize,
          offset: productListModel?.offset,
          onPaginate: (int? offset) async {
            if (offset != null) {
              await categoryProvider.getCategoryProducts(categoryId, offset);
            }
          },
          itemView: Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ).copyWith(bottom: MediaQuery.of(context).padding.bottom),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisSpacing: Dimensions.paddingSizeSmall,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _AuctionProductCard(product: products[index]);
              },
            ),
          ),
        );
      },
    );
  }
}

class _AuctionProductCard extends StatelessWidget {
  final AuctionProduct product;
  const _AuctionProductCard({required this.product});

  AuctionCardState _resolveState(String? status) {
    switch (status) {
      case 'live':
        return AuctionCardState.live;
      case 'upcoming':
        return AuctionCardState.upcoming;
      default:
        return AuctionCardState.upcoming;
    }
  }

  DateTime? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      return DateTime.parse(timeStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = product.auctionDetails;
    final cardState = _resolveState(details?.status);

    final targetTime = cardState == AuctionCardState.live ? _parseTime(details?.endTime) : _parseTime(details?.startTime);

    return AuctionCardWidget(
      slug: product.slug ?? '',
      state: cardState,
      imageUrl: product.thumbnailFullUrl?.path ?? '',
      productName: product.name ?? '',
      price: (product.startingPrice ?? 0).toDouble(),
      targetTime: targetTime ?? DateTime.now().add(const Duration(hours: 1)),
      viewCount: details?.totalViews ?? 0,
      bidCount: details?.totalBids,
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String? title;
  final bool isSelected;
  const _CategoryItem({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeTwelve),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).cardColor : Colors.transparent,
        borderRadius: isSelected ? BorderRadius.zero
            : const BorderRadius.only(
                topRight: Radius.circular(Dimensions.paddingSizeDefault),
                bottomRight: Radius.circular(Dimensions.paddingSizeDefault),
              ),
      ),
      child: Text(title ?? '', maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: isSelected
            ? titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ) : titilliumSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor.withValues(alpha: 0.8),
              ),
      ),
    );
  }
}

class _AuctionCategoryScreenShimmer extends StatelessWidget {
  const _AuctionCategoryScreenShimmer();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color shimmerColor = isDark ? Theme.of(context).primaryColor.withValues(alpha: .05) : Theme.of(context).cardColor;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              padding: EdgeInsets.zero,
              itemBuilder: (_, __) => Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: shimmerColor,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Container(
                      height: 10,
                      width: 40,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Expanded(flex: 7, child: _AuctionProductPanelShimmer()),
        ],
      ),
    );
  }
}

class _AuctionProductPanelShimmer extends StatelessWidget {
  const _AuctionProductPanelShimmer();

  @override
  Widget build(BuildContext context) {

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisSpacing: Dimensions.paddingSizeSmall,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const AuctionCardShimmerWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
