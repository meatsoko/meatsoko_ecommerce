import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/category_content_screen_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/category_product_filter_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/debounce_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
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
  final DebounceHelper _debounceHelper = DebounceHelper(milliseconds: 500);
  String _activeSearchQuery = '';

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
        final products = model?.products ?? [];

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
              SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),

              if (!isLoading)
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

              if (isLoading)
                const SliverToBoxAdapter(child: CategoryContentScreenShimmer())
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_products_found', context)),
                )
              else
                SliverToBoxAdapter(
                  child: PaginatedListView(
                    scrollController: _scrollController,
                    totalSize: model.totalSize,
                    offset: model.offset,
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
            ],
          ),
        );
      },
    );
  }

  void _searchProducts(int categoryId) {
    final query = searchTextEditingController.text.trim();
    if (query.isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_somethings', context), Get.context!, snackBarType: SnackBarType.warning);
      return;
    }
    _debounceHelper.run(() {
      _activeSearchQuery = query;
      final productController = Provider.of<ProductController>(context, listen: false);
      productController.clearCategoryProductFor(categoryId);
      productController.getCategoryProducts(categoryId, 1, searchProduct: _activeSearchQuery);
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
            onChanged: (value) => setState(() {}),
            onFieldSubmitted: (value) => _searchProducts(categoryId),
            style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                hintText: getTranslated('search_products', context),
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