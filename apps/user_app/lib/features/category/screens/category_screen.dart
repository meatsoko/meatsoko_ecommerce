import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_app/common/basewidget/buttons_tab_bar.dart';
import 'package:user_app/common/basewidget/custom_app_bar_widget.dart';
import 'package:user_app/common/basewidget/custom_asset_image_widget.dart';
import 'package:user_app/common/basewidget/no_internet_screen_widget.dart';
import 'package:user_app/common/basewidget/paginated_list_view_widget.dart';
import 'package:user_app/common/basewidget/product_card_shimmer_widget.dart';
import 'package:user_app/common/basewidget/product_card_widget.dart';
import 'package:user_app/features/cart/controllers/cart_controller.dart';
import 'package:user_app/features/category/controllers/category_controller.dart';
import 'package:user_app/features/category/domain/models/category_model.dart';
import 'package:user_app/features/product/controllers/product_controller.dart';
import 'package:user_app/features/product/domain/models/product_model.dart';
import 'package:user_app/features/product/enums/product_type.dart';
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

  const _SpecialCategoryTile({required this.label, required this.asset, required this.matchTerm});
}

const List<_SpecialCategoryTile> _specialCategoryTiles = [
  _SpecialCategoryTile(label: 'Goat Meat', asset: 'assets/image/category_goat_meat.png', matchTerm: 'goat'),
  _SpecialCategoryTile(label: 'Mutton', asset: 'assets/image/category_mutton.png', matchTerm: 'mutton'),
  _SpecialCategoryTile(label: 'Offal', asset: 'assets/image/category_offal.png', matchTerm: 'offal'),
  _SpecialCategoryTile(label: 'Bones & Soup', asset: 'assets/image/category_bones_soup.png', matchTerm: 'bone'),
  _SpecialCategoryTile(label: 'Whole Animal', asset: 'assets/image/category_whole_animal.png', matchTerm: 'whole'),
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

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  int? _selectedCategoryId;

  late final TabController _productTypeTabController;
  static const List<ProductType> _productTypes = [
    ProductType.newArrival,
    ProductType.topProduct,
    ProductType.bestSelling,
    ProductType.discountedProduct,
  ];

  @override
  void initState() {
    super.initState();
    _productTypeTabController = TabController(length: _productTypes.length, vsync: this);
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _productTypeTabController.dispose();
    super.dispose();
  }

  // Real cuts like "Goat"/"Mutton"/"Offal" live as *subcategory* names under
  // a top-level "Meat" category here (confirmed against the live site — see
  // xdocs/review.md's crawled breadcrumb "Meat -> Mutton & Goat Meat ->
  // Full Whole Goat Carcass") — matching only top-level names, as the first
  // version of this did, meant these tiles could never match anything and
  // were permanently dead. Search top-level, then subcategories, then
  // sub-subcategories, and use whichever level actually matched.
  int? _matchedCategoryId(_SpecialCategoryTile tile, List<CategoryModel> categories) {
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
    setState(() => _selectedCategoryId = _selectedCategoryId == matchedId ? null : matchedId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: getTranslated('CATEGORY', context),
        isBackButtonExist: widget.isBacButtonExist,
        centerTitle: false,
        actions: [_CartButton(), const SizedBox(width: Dimensions.paddingSizeSmall)],
      ),
      body: Consumer<CategoryController>(
        builder: (context, categoryProvider, _) {
          final categories = categoryProvider.categoryList;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildSearchBar(context),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              _buildCategoryStrip(context, categories),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Expanded(
                child: _selectedCategoryId != null
                    ? _CategoryProductGrid(key: ValueKey(_selectedCategoryId), categoryId: _selectedCategoryId!)
                    : _ProductTypeGrid(controller: _productTypeTabController, productTypes: _productTypes),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              onTap: () => RouterHelper.getSearchRoute(action: RouteAction.push),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(children: [
                  Icon(Icons.search, color: Theme.of(context).hintColor, size: 22),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      getTranslated('search_hint', context) ?? 'Search for products...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
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
              height: 48, width: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.qr_code_scanner, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStrip(BuildContext context, List<CategoryModel> categories) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
        itemCount: _specialCategoryTiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
        itemBuilder: (context, index) {
          final tile = _specialCategoryTiles[index];
          final matchedId = _matchedCategoryId(tile, categories);
          final isSelected = matchedId != null && matchedId == _selectedCategoryId;
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
}

class _CartButton extends StatelessWidget {
  const _CartButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil, page: 'cart'),
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        height: 40, width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          Center(child: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20)),
          Consumer<CartController>(
            builder: (context, cart, _) => cart.cartList.isNotEmpty
                ? Positioned(
                    right: -2, top: -2,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: BrandColors.burgundy,
                      child: Text('${cart.cartList.length}', style: textBold.copyWith(color: Colors.white, fontSize: 9)),
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

  const _CategoryTile({required this.title, required this.asset, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      onTap: onTap,
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: isSelected ? Border.all(color: BrandColors.burgundy, width: 1.4) : null,
          boxShadow: isSelected ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomAssetImageWidget(asset, height: 56, width: 56, fit: BoxFit.cover),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: isSelected ? BrandColors.burgundy : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Default "browse everything" view — the filter mechanism moved over from
/// Home (New Arrival / Top / Best Selling / Discounted), shown whenever no
/// special-category tile is selected.
class _ProductTypeGrid extends StatelessWidget {
  final TabController controller;
  final List<ProductType> productTypes;

  const _ProductTypeGrid({required this.controller, required this.productTypes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
          child: ButtonsTabBar(
            controller: controller,
            tabs: productTypes.map((type) => type.displayName(context)).toList(),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: productTypes.map((type) => _ProductTypeListItem(productType: type)).toList(),
          ),
        ),
      ],
    );
  }
}

class _ProductTypeListItem extends StatefulWidget {
  final ProductType productType;

  const _ProductTypeListItem({required this.productType});

  @override
  State<_ProductTypeListItem> createState() => _ProductTypeListItemState();
}

class _ProductTypeListItemState extends State<_ProductTypeListItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).getProductsForTypeDebounced(widget.productType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductModel?>(
      selector: (_, controller) => controller.productModelForType(widget.productType),
      builder: (context, selectedProductModel, _) {
        final products = selectedProductModel?.products;

        if (products == null) {
          return const _ProductGridShimmer();
        }

        if (products.isEmpty) {
          return NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_product_found', context) ?? '');
        }

        return Padding(
          padding: const EdgeInsets.all(11),
          child: MasonryGridView.count(
            cacheExtent: 600,
            key: PageStorageKey(widget.productType),
            crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
            itemCount: products.length,
            itemBuilder: (context, index) => RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: ProductCardWidget(key: ValueKey(products[index].id), product: products[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shown once a special-category tile is selected — that category's real,
/// paginated product grid (same ProductController.getCategoryProducts data
/// path HomeCategoryContent uses, just without its own nested search bar
/// since this page already has one above).
class _CategoryProductGrid extends StatefulWidget {
  final int categoryId;

  const _CategoryProductGrid({super.key, required this.categoryId});

  @override
  State<_CategoryProductGrid> createState() => _CategoryProductGridState();
}

class _CategoryProductGridState extends State<_CategoryProductGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).getCategoryProductsDebounced(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, _) {
        final model = productController.categoryProductsFor(widget.categoryId);
        final bool isLoading = model == null;
        final products = model?.products ?? [];

        if (isLoading) {
          return const _ProductGridShimmer();
        }

        if (products.isEmpty) {
          return NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_products_found', context));
        }

        return RefreshIndicator(
          onRefresh: () async {
            productController.clearCategoryProductFor(widget.categoryId);
            await productController.getCategoryProducts(widget.categoryId, 1);
          },
          // PaginatedListView doesn't provide its own scroll container — it
          // only listens on the given scrollController to know when to
          // paginate — so the shrinkWrap+NeverScrollableScrollPhysics grid
          // below needs a real scrollable ancestor to actually scroll.
          child: SingleChildScrollView(
            controller: _scrollController,
            child: PaginatedListView(
              scrollController: _scrollController,
              totalSize: model.totalSize,
              offset: model.offset,
              onPaginate: (offset) => productController.getCategoryProducts(widget.categoryId, offset ?? 1),
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
            ),
          ),
        );
      },
    );
  }
}

class _ProductGridShimmer extends StatelessWidget {
  const _ProductGridShimmer();

  static const List<double> _imageHeights = [
    150, 120, 160, 110, 140, 130,
    125, 155, 115, 145, 135, 120,
  ];

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = ResponsiveHelper.isTab(context) ? 3 : 2;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: MasonryGridView.count(
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
