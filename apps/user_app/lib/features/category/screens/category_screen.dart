import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_app/common/basewidget/custom_app_bar_widget.dart';
import 'package:user_app/common/basewidget/custom_asset_image_widget.dart';
import 'package:user_app/common/basewidget/no_internet_screen_widget.dart';
import 'package:user_app/common/basewidget/paginated_list_view_widget.dart';
import 'package:user_app/common/basewidget/product_card_shimmer_widget.dart';
import 'package:user_app/common/basewidget/product_card_widget.dart';
// import 'package:user_app/common/basewidget/todays_deal_section_widget.dart';
import 'package:user_app/features/cart/controllers/cart_controller.dart';
import 'package:user_app/features/category/controllers/category_controller.dart';
import 'package:user_app/features/category/domain/models/category_model.dart';
import 'package:user_app/features/clearance_sale/widgets/clearance_sale_list_widget.dart';
import 'package:user_app/features/home/widgets/redesign/banner_slider_widget.dart';
import 'package:user_app/features/home/widgets/redesign/new_user_exclusive_section.dart';
import 'package:user_app/features/home/widgets/redesign/top_stores_widget.dart';
import 'package:user_app/features/product/controllers/product_controller.dart';
import 'package:user_app/features/product/domain/models/product_model.dart';
import 'package:user_app/features/product/enums/product_type.dart';
import 'package:user_app/features/splash/controllers/splash_controller.dart';
import 'package:user_app/helper/product_type_extension.dart';
import 'package:user_app/helper/responsive_helper.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/brand_colors.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';

/// Fixed, curated tiles for the category icon strip (same artwork/matching
/// pattern as Home's category grid — see category_morph_header.dart) minus
/// "More", since this page already *is* the full category browser.
class _SpecialCategoryTile {
  final String label;
  final String asset;
  final String matchTerm;

  const _SpecialCategoryTile(
      {required this.label, required this.asset, required this.matchTerm});
}

const List<_SpecialCategoryTile> _specialCategoryTiles = [
  _SpecialCategoryTile(
      label: 'Goat Meat',
      asset: 'assets/image/category_goat_meat.png',
      matchTerm: 'goat'),
  _SpecialCategoryTile(
      label: 'Mutton',
      asset: 'assets/image/category_mutton.png',
      matchTerm: 'mutton'),
  _SpecialCategoryTile(
      label: 'Offal',
      asset: 'assets/image/category_offal.png',
      matchTerm: 'offal'),
  _SpecialCategoryTile(
      label: 'Bones & Soup',
      asset: 'assets/image/category_bones_soup.png',
      matchTerm: 'bone'),
  _SpecialCategoryTile(
      label: 'Whole Animal',
      asset: 'assets/image/category_whole_animal.png',
      matchTerm: 'whole'),
];

const List<ProductType> _productTypes = [
  ProductType.newArrival,
  ProductType.topProduct,
  ProductType.bestSelling,
  ProductType.discountedProduct,
];

class CategoryScreen extends StatefulWidget {
  final bool isBacButtonExist;
  final int? initialCategoryId;
  final String? initialCategoryName;

  const CategoryScreen({
    super.key,
    this.isBacButtonExist = true,
    this.initialCategoryId,
    this.initialCategoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int? _selectedCategoryId;
  ProductType _selectedProductType = ProductType.newArrival;
  final ScrollController _scrollController = ScrollController();
  late final bool _singleVendor;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    final splash = Provider.of<SplashController>(context, listen: false);
    _singleVendor = splash.configModel?.businessMode == 'single';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Real cuts like "Goat"/"Mutton"/"Offal" live as *subcategory* names under
  // a top-level "Meat" category here (confirmed against the live site — see
  // xdocs/review.md's crawled breadcrumb "Meat -> Mutton & Goat Meat ->
  // Full Whole Goat Carcass") — matching only top-level names, as the first
  // version of this did, meant these tiles could never match anything and
  // were permanently dead. Search top-level, then subcategories, then
  // sub-subcategories, and use whichever level actually matched.
  int? _matchedCategoryId(
      _SpecialCategoryTile tile, List<CategoryModel> categories) {
    for (final category in categories) {
      if ((category.name ?? '').toLowerCase().contains(tile.matchTerm)) {
        return category.id;
      }
      for (final sub in category.subCategories ?? const []) {
        if ((sub.name ?? '').toLowerCase().contains(tile.matchTerm)) {
          return sub.id;
        }
        for (final subSub in sub.subSubCategories ?? const []) {
          if ((subSub.name ?? '').toLowerCase().contains(tile.matchTerm)) {
            return subSub.id;
          }
        }
      }
    }
    return null;
  }

  void _toggleTile(int matchedId) {
    setState(() => _selectedCategoryId =
        _selectedCategoryId == matchedId ? null : matchedId);
  }

  // Label of whichever special-category tile is currently selected, so the
  // app bar can show what you're inside instead of the generic "CATEGORY"
  // title while a category is drilled into.
  String? _selectedTileLabel(List<CategoryModel> categories) {
    for (final tile in _specialCategoryTiles) {
      if (_matchedCategoryId(tile, categories) == _selectedCategoryId) {
        return tile.label;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryProvider, _) {
        final categories = categoryProvider.categoryList;
        final bool inSpecificCategory = _selectedCategoryId != null;

        return Scaffold(
          appBar: CustomAppBar(
            title: inSpecificCategory
                ? (_selectedTileLabel(categories) ?? getTranslated('CATEGORY', context))
                : getTranslated('CATEGORY', context),
            // This tab normally has no back button (it's a bottom-nav root),
            // but once a specific category is selected there needs to be an
            // explicit way back to the default browse-everything view rather
            // than relying on re-tapping the already-selected tile.
            isBackButtonExist: widget.isBacButtonExist || inSpecificCategory,
            onBackPressed: inSpecificCategory
                ? () => setState(() => _selectedCategoryId = null)
                : null,
            centerTitle: false,
            actions: [
              _CartButton(),
              const SizedBox(width: Dimensions.paddingSizeSmall)
            ],
          ),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(
                  child: SizedBox(height: Dimensions.paddingSizeSmall)),
              SliverToBoxAdapter(
                  child: _buildCategoryStrip(context, categories)),
              const SliverToBoxAdapter(
                  child: SizedBox(height: Dimensions.paddingSizeDefault)),
              SliverToBoxAdapter(child: _buildSearchBar(context)),
              const SliverToBoxAdapter(
                  child: SizedBox(height: Dimensions.paddingSizeSmall)),
              if (_selectedCategoryId != null)
                _CategorySliverGrid(
                    categoryId: _selectedCategoryId!,
                    scrollController: _scrollController)
              else ...[
                // Filter chips lead right after the search bar now, with
                // everything else (merchandising sections + the filtered
                // grid they drive) following below.
                SliverToBoxAdapter(child: _buildProductTypeFilterBar(context)),
                const SliverToBoxAdapter(
                    child: SizedBox(height: Dimensions.paddingSizeSmall)),

                // Everything that used to live below Featured Products on
                // Home, moved here — this is the default "browse everything"
                // state (no special-category tile selected).
                const SliverToBoxAdapter(child: ClearanceListWidget()),
                // const SliverToBoxAdapter(child: TodaysDealSectionWidget()),
                const SliverToBoxAdapter(child: NewUserExclusiveSection()),
                if (!_singleVendor)
                  const SliverToBoxAdapter(child: TopStoresWidget()),
                const SliverToBoxAdapter(
                    child: BannersSliderWidget(useFooterBanners: true)),
                _ProductTypeSliverGrid(productType: _selectedProductType),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              onTap: () =>
                  RouterHelper.getSearchRoute(action: RouteAction.push),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(children: [
                  Icon(Icons.search,
                      color: Theme.of(context).hintColor, size: 22),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      getTranslated('search_hint', context) ??
                          'Search for products...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: () => RouterHelper.getSearchRoute(action: RouteAction.push),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Icon(Icons.qr_code_scanner,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStrip(
      BuildContext context, List<CategoryModel> categories) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
        itemCount: _specialCategoryTiles.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: Dimensions.paddingSizeSmall),
        itemBuilder: (context, index) {
          final tile = _specialCategoryTiles[index];
          final matchedId = _matchedCategoryId(tile, categories);
          final isSelected =
              matchedId != null && matchedId == _selectedCategoryId;
          return _CategoryTile(
            title: tile.label,
            asset: tile.asset,
            isSelected: isSelected,
            onTap: matchedId == null ? null : () => _toggleTile(matchedId),
          );
        },
      ),
    );
  }

  Widget _buildProductTypeFilterBar(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
        itemCount: _productTypes.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: Dimensions.paddingSizeSmall),
        itemBuilder: (context, index) {
          final type = _productTypes[index];
          final isSelected = type == _selectedProductType;
          return InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => setState(() => _selectedProductType = type),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: isSelected
                    ? BrandColors.burgundy
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(100),
                border: isSelected
                    ? null
                    : Border.all(
                        color:
                            Theme.of(context).hintColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                type.displayName(context),
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => RouterHelper.getDashboardRoute(
          action: RouteAction.pushNamedAndRemoveUntil, page: 'cart'),
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          Center(
              child: Icon(Icons.shopping_cart_outlined,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  size: 20)),
          Consumer<CartController>(
            builder: (context, cart, _) => cart.cartList.isNotEmpty
                ? Positioned(
                    right: -2,
                    top: -2,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: BrandColors.burgundy,
                      child: Text('${cart.cartList.length}',
                          style: textBold.copyWith(
                              color: Colors.white, fontSize: 9)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final String asset;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryTile(
      {required this.title,
      required this.asset,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      onTap: onTap,
      child: Container(
        width: 78,
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: isSelected
              ? Border.all(color: BrandColors.burgundy, width: 1.4)
              : null,
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomAssetImageWidget(asset,
                  height: 56, width: 56, fit: BoxFit.cover),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraSmall),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: isSelected
                      ? BrandColors.burgundy
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Default "browse everything" grid — the filter mechanism moved over from
/// Home (New Arrival / Top / Best Selling / Discounted), rendered as a
/// sliver so it can live alongside the other moved sections in the same
/// CustomScrollView instead of needing its own nested scrollable.
class _ProductTypeSliverGrid extends StatefulWidget {
  final ProductType productType;

  const _ProductTypeSliverGrid({required this.productType});

  @override
  State<_ProductTypeSliverGrid> createState() => _ProductTypeSliverGridState();
}

class _ProductTypeSliverGridState extends State<_ProductTypeSliverGrid> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false)
          .getProductsForTypeDebounced(widget.productType);
    });
  }

  @override
  void didUpdateWidget(covariant _ProductTypeSliverGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productType != widget.productType) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ProductController>(context, listen: false)
            .getProductsForTypeDebounced(widget.productType);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<ProductController, ProductModel?>(
        selector: (_, controller) =>
            controller.productModelForType(widget.productType),
        builder: (context, selectedProductModel, _) {
          final products = selectedProductModel?.products;

          if (products == null) {
            return const _ProductGridShimmer();
          }

          if (products.isEmpty) {
            return NoInternetOrDataScreenWidget(
                isNoInternet: false,
                message: getTranslated('no_product_found', context) ?? '');
          }

          return Padding(
            padding: const EdgeInsets.all(11),
            child: MasonryGridView.count(
              cacheExtent: 600,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              key: PageStorageKey(widget.productType),
              crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
              itemCount: products.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: ProductCardWidget(
                    key: ValueKey(products[index].id),
                    product: products[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shown once a special-category tile is selected — that category's real,
/// paginated product grid (same ProductController.getCategoryProducts data
/// path HomeCategoryContent uses). scrollController is the *same* one bound
/// to this screen's outer CustomScrollView, which is what lets
/// PaginatedListView's "reached the bottom" detection work — it only
/// listens on a given controller, it doesn't provide its own scrollable.
class _CategorySliverGrid extends StatefulWidget {
  final int categoryId;
  final ScrollController scrollController;

  const _CategorySliverGrid(
      {super.key, required this.categoryId, required this.scrollController});

  @override
  State<_CategorySliverGrid> createState() => _CategorySliverGridState();
}

class _CategorySliverGridState extends State<_CategorySliverGrid> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false)
          .getCategoryProductsDebounced(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<ProductController>(
        builder: (context, productController, _) {
          final model =
              productController.categoryProductsFor(widget.categoryId);
          final bool isLoading = model == null;
          final products = model?.products ?? [];

          if (isLoading) {
            return const _ProductGridShimmer();
          }

          if (products.isEmpty) {
            return NoInternetOrDataScreenWidget(
                isNoInternet: false,
                message: getTranslated('no_products_found', context));
          }

          return PaginatedListView(
            scrollController: widget.scrollController,
            totalSize: model.totalSize,
            offset: model.offset,
            onPaginate: (offset) => productController.getCategoryProducts(
                widget.categoryId, offset ?? 1),
            itemView: MasonryGridView.count(
              cacheExtent: 600,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
              itemCount: products.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: ProductCardWidget(product: products[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGridShimmer extends StatelessWidget {
  const _ProductGridShimmer();

  static const List<double> _imageHeights = [
    150,
    120,
    160,
    110,
    140,
    130,
    125,
    155,
    115,
    145,
    135,
    120,
  ];

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = ResponsiveHelper.isTab(context) ? 3 : 2;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        itemCount: _imageHeights.length,
        itemBuilder: (context, index) {
          final double imageHeight = _imageHeights[index];
          return Container(
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: ProductCardShimmerWidget(imageHeight: imageHeight),
          );
        },
      ),
    );
  }
}
