import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/category_content_screen_shimmer.dart';
import 'package:user_app/common/basewidget/no_internet_screen_widget.dart';
import 'package:user_app/common/basewidget/paginated_list_view_widget.dart';
import 'package:user_app/common/basewidget/product_card_widget.dart';
import 'package:user_app/features/category/controllers/category_controller.dart';
import 'package:user_app/features/product/controllers/product_controller.dart';
import 'package:user_app/features/product/domain/models/product_model.dart';
import 'package:user_app/helper/debounce_helper.dart';
import 'package:user_app/helper/responsive_helper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/utill/images.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class HomeCategoryContent extends StatelessWidget {
  final String categoryName;
  final int categoryIndex;
  const HomeCategoryContent({
    super.key,
    required this.categoryName,
    required this.categoryIndex,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryContentBody(categoryName: categoryName, categoryIndex: categoryIndex);
  }
}

class _CategoryContentBody extends StatefulWidget {
  final String categoryName;
  final int categoryIndex;

  const _CategoryContentBody({
    required this.categoryName,
    required this.categoryIndex,
  });

  @override
  State<_CategoryContentBody> createState() => _CategoryContentBodyState();
}

class _CategoryContentBodyState extends State<_CategoryContentBody> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchTextEditingController = TextEditingController();
  final DebounceHelper _debounceHelper = DebounceHelper(milliseconds: 400);
  String _activeSearchQuery = '';
  // Last successfully loaded page, kept so an in-flight search doesn't blank
  // the tab (see the build method).
  List<Product> _lastProducts = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      categoryController.onChangeSelectedIndex(widget.categoryIndex, isUpdate: false);
      final categoryId = categoryController.categoryList[widget.categoryIndex].id;
      if (categoryId != null) {
        Provider.of<ProductController>(context, listen: false).getCategoryProductsDebounced(categoryId);
      }
    });
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final categoryId = Provider.of<CategoryController>(context, listen: false).categoryList[widget.categoryIndex].id ?? -1;

    return Consumer<ProductController>(
      builder: (context, productController, _) {

        final model = productController.categoryProductsFor(categoryId);
        final bool isLoading = model == null;
        // getCategoryProducts() nulls the cached model on every offset-1 fetch,
        // so a search would otherwise blank the whole tab (search bar included)
        // until results landed. Hold on to the previous results and keep
        // rendering them while the next set loads.
        if (model?.products != null) {
          _lastProducts = model!.products!;
        }
        final products = model?.products ?? (isLoading ? _lastProducts : const <Product>[]);
        final bool showStaleResults = isLoading && _lastProducts.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () async {
            final productController = Provider.of<ProductController>(context, listen: false);
            productController.clearCategoryProductFor(categoryId);
            await productController.getCategoryProducts(categoryId, 1, searchProduct: _activeSearchQuery);
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Always mounted — previously gated on `!isLoading`, so the field
              // the user was typing in disappeared on every keystroke-triggered
              // search and came back as a new widget (losing focus).
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverSearchBarDelegate(
                  height: 70,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: _buildSearchBar(context, categoryId),
                  ),
                ),
              ),

              if (isLoading && !showStaleResults)
                const SliverToBoxAdapter(child: CategoryContentScreenShimmer())
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_products_found', context)),
                )
              else
                SliverToBoxAdapter(
                  // Dimmed while a newer result set is in flight, so it reads
                  // as "updating" rather than as final content.
                  child: Opacity(
                    opacity: showStaleResults ? 0.45 : 1.0,
                    child: PaginatedListView(
                    scrollController: _scrollController,
                    totalSize: model?.totalSize ?? products.length,
                    offset: model?.offset ?? 1,
                    onPaginate: (offset) {
                      Provider.of<ProductController>(context, listen: false).getCategoryProducts(categoryId, offset ?? 1, searchProduct: _activeSearchQuery);
                    },
                    itemView: MasonryGridView.count(
                      cacheExtent: 600,
                      key: PageStorageKey(widget.categoryIndex),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeEight)
                          .copyWith(bottom: MediaQuery.of(context).padding.bottom),
                      crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: ProductCardWidget(product: products[index]),
                        );
                      },
                    ),
                  ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Live search — runs as the user types (debounced). An empty query is a
  /// valid state that restores the full category listing, rather than the
  /// warning snackbar this used to show on submit.
  void _searchProducts(int categoryId) {
    final query = searchTextEditingController.text.trim();
    _debounceHelper.run(() {
      if (!mounted || query == _activeSearchQuery) return;
      _activeSearchQuery = query;
      // No clearCategoryProductFor here: getCategoryProducts() already resets
      // the cached model for offset 1, and clearing twice caused an extra
      // blank frame.
      Provider.of<ProductController>(context, listen: false)
          .getCategoryProducts(categoryId, 1, searchProduct: _activeSearchQuery);
    });
  }

  void _clearSearch(int categoryId) {
    searchTextEditingController.clear();
    _activeSearchQuery = '';
    final productController = Provider.of<ProductController>(context, listen: false);
    productController.clearCategoryProductFor(categoryId);
    productController.getCategoryProducts(categoryId, 1);
    setState(() {});
  }




  Widget _buildSearchBar(BuildContext context, int categoryId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeSmall).copyWith(right: Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
            controller: searchTextEditingController,
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              setState(() {});          // refresh the clear-button affordance
              _searchProducts(categoryId); // debounced live search
            },
            onFieldSubmitted: (value) => _searchProducts(categoryId),
            style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
            decoration: InputDecoration(
                isDense: true,
                // Same rounded, borderless, filled pill as SearchBarPillWidget
                // (the bar users tap elsewhere in the app), so this reads as
                // the same control rather than a different one.
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault, vertical: 14),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor, size: 22),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    borderSide: BorderSide.none),
                hintText: getTranslated('search_hint', context) ?? 'Search for products...',
                hintStyle: textRegular.copyWith(color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.9)),
                suffixIcon: SizedBox(width: searchTextEditingController.text.isNotEmpty ? 70 : 50,
                  child: Row(children: [
                    if(searchTextEditingController.text.isNotEmpty)
                      InkWell(
                        onTap: () => _clearSearch(categoryId),
                        child: const Icon(Icons.clear, size: 20,),
                      ),

                    InkWell(
                      onTap: () => _searchProducts(categoryId),
                      child: Container(
                        margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        child: Image.asset(Images.search, color: Colors.white, height: Dimensions.iconSizeSmall, width: Dimensions.iconSizeSmall, fit: BoxFit.contain),
                      ),
                    ),
                  ]),
                )
            ),
          ),
          ),


          // SizedBox(width: Dimensions.paddingSizeSmall),
          // InkWell(
          //   onTap: () {
          //     showModalBottomSheet(
          //       context: context,
          //       isScrollControlled: true,
          //       backgroundColor: Colors.transparent,
          //       builder: (_) => CategoryProductFilterDialog(categoryId: categoryId),
          //     );
          //   },
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Theme.of(context).cardColor,
          //       borderRadius: BorderRadius.circular(5),
          //       border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
          //     ),
          //     padding: const EdgeInsets.all(Dimensions.paddingSizeTwelve),
          //     child: CustomAssetImageWidget(Images.filterIcon, height: 20, width: 20)
          //   ),
          // )

        ],
      )

    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  const _SliverSearchBarDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SliverSearchBarDelegate oldDelegate) => oldDelegate.child != child || oldDelegate.height != height;
}