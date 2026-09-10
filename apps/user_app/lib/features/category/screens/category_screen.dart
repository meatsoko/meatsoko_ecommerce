import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_app/common/basewidget/custom_app_bar_widget.dart';
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
import 'package:user_app/features/search_product/controllers/search_product_controller.dart';
import 'package:user_app/features/search_product/widgets/search_product_widget.dart';
import 'package:user_app/common/basewidget/product_shimmer_widget.dart';
import 'package:user_app/helper/debounce_helper.dart';
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
  /// Open with the search field already focused (keyboard up) — used when
  /// arriving from Home's search bar, so the user types straight away.
  final bool initialFocusSearch;

  const CategoryScreen({
    super.key,
    this.isBacButtonExist = true,
    this.initialCategoryId,
    this.initialCategoryName,
    this.initialFocusSearch = false,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int? _selectedCategoryId;
  ProductType _selectedProductType = ProductType.newArrival;
  final ScrollController _scrollController = ScrollController();
  late final bool _singleVendor;
  // Inline live search — this page's own search bar is the real input; there
  // is no hand-off to the separate Search screen.
  final TextEditingController _searchController = TextEditingController();
  final DebounceHelper _searchDebounce = DebounceHelper(milliseconds: 400);
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    final splash = Provider.of<SplashController>(context, listen: false);
    _singleVendor = splash.configModel?.businessMode == 'single';

    if (widget.initialFocusSearch) {
      // After first frame so the field exists and the route transition has
      // settled — focusing mid-push makes the keyboard animation stutter.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});                     // refresh the clear affordance
    _searchDebounce.run(() {
      if (!mounted) return;
      final q = value.trim();
      if (q == _query) return;
      setState(() => _query = q);
      final search = Provider.of<SearchProductController>(context, listen: false);
      if (q.isEmpty) {
        search.cleanSearchProduct(notify: true);
      } else {
        search.searchProduct(query: q, offset: 1);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    Provider.of<SearchProductController>(context, listen: false)
        .cleanSearchProduct(notify: true);
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.homePagePadding),
                  child: _buildLiveSearchField(context),
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: Dimensions.paddingSizeSmall)),
              // Live results replace the browse content while a query is active.
              if (_query.isNotEmpty)
                ..._searchResultSlivers()
              else if (_selectedCategoryId != null)
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

  /// The page's one and only search bar: a real input styled as the same
  /// rounded pill used elsewhere. Deliberately no trailing burgundy submit
  /// button and no navigation — searching happens live, in place, so there is
  /// never a second search bar to tap through to.
  Widget _buildLiveSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      textInputAction: TextInputAction.search,
      onChanged: _onSearchChanged,
      onSubmitted: _onSearchChanged,
      style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault, vertical: 14),
        prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor, size: 22),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.clear, size: 20, color: Theme.of(context).hintColor),
                onPressed: _clearSearch,
              ),
        hintText: getTranslated('search_hint', context) ?? 'Search for products...',
        hintStyle: textRegular.copyWith(
            color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            borderSide: BorderSide.none),
      ),
    );
  }

  /// Results for the active query, rendered in place of the browse content.
  List<Widget> _searchResultSlivers() {
    return [
      Consumer<SearchProductController>(
        builder: (context, search, _) {
          final loading = search.isLoading && search.searchedProduct == null;
          if (loading) {
            return const SliverToBoxAdapter(
                child: ProductShimmer(isHomePage: false, isEnabled: true));
          }
          // SearchProductWidget lays out a fixed header + Expanded list, so it
          // needs a bounded height — SliverFillRemaining supplies the rest of
          // the viewport. A SliverToBoxAdapter would leave it unbounded.

          final hasResults = (search.searchedProduct?.products?.isNotEmpty ?? false) ||
              search.isFilterApplied || search.isSortingApplied;
          if (!hasResults) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: NoInternetOrDataScreenWidget(
                  isNoInternet: false,
                  message: getTranslated('no_products_found', context)),
            );
          }
          return const SliverFillRemaining(
              hasScrollBody: true, child: SearchProductWidget());
        },
      ),
    ];
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
      onTap: () => RouterHelper.getCartScreenRoute(action: RouteAction.push),
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
