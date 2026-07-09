import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/buttons_tab_bar.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/todays_deal_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/auction_product_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/banner_slider_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/featured_products_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/flash_deal_section.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/new_user_exclusive_section.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/redesign/top_stores_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class HomeExploreContent extends StatefulWidget {
  final TabController tabController;
  final TabController productTabController;
  final List<ProductType> types;

  const HomeExploreContent({
    super.key,
    required this.tabController,
    required this.productTabController,
    required this.types,
  });

  @override
  State<HomeExploreContent> createState() => _HomeExploreContentState();
}

class _HomeExploreContentState extends State<HomeExploreContent> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool singleVendor = Provider.of<SplashController>(context, listen: false).configModel?.businessMode == "single";

    if (widget.tabController.index == 0) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: _HomeFeedWidget(singleVendor: singleVendor, productTabController: widget.productTabController,
              types: widget.types,),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: widget.productTabController,
              children: widget.types.map((type) => _ListItemWidget(productType: type)).toList(),
            ),
          ),
        ],
      );
    }

    return Consumer<ProductController>(
      builder: (context, productController, _) {
        final int categoryCount = (productController.homeCategoryProductList.length) + 1;

        return SliverFillRemaining(
          child: TabBarView(
            controller: widget.tabController,
            children: List<int>.generate(categoryCount, (index) => index).map((value) => SafeArea(
                top: false,
                bottom: false,
                child: Builder(
                  builder: (context) => CustomScrollView(
                    scrollBehavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                      Consumer<ProductController>(
                        builder: (context, productController, _) {
                          final products = productController.latestProductModel?.products;

                          return SliverFillRemaining(
                            child: products == null ? const Center(child: CircularProgressIndicator())
                                : MasonryGridView.count(
                              cacheExtent: 5000,
                              key: PageStorageKey(widget.tabController.index),
                              itemCount: products.length,
                              crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
                              itemBuilder: (context, index) =>
                                  Container(margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                    child: ProductCardWidget(product: products[index])),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ).toList(),
          ),
        );
      },
    );
  }
}

class _HomeFeedWidget extends StatelessWidget {
  final bool singleVendor;
  final TabController productTabController;
  final List<ProductType> types;

  const _HomeFeedWidget({
    required this.singleVendor,
    required this.productTabController,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAuctionEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAuctionFeatureEnabled ?? false;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),
        const FlashDealSection(),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        const BannersSliderWidget(),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        const FeaturedProductsWidget(),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        TodaysDealSectionWidget(),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        if(isAuctionEnabled)
        AuctionProductSectionWidget(),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        const NewUserExclusiveSection(),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        if (!singleVendor) const TopStoresWidget(),
        if (!singleVendor) const SizedBox(height: Dimensions.paddingSizeLarge),

        ButtonsTabBar(controller: productTabController, tabs: types.map((type) => getTranslated(type.name, context) ?? type.name).toList()),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    );
  }
}

class _ListItemWidget extends StatefulWidget {
  final ProductType productType;

  const _ListItemWidget({required this.productType});

  @override
  State<_ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<_ListItemWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).onChangeSelectedProductType(widget.productType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, _) {
        final products = productController.selectedProductModel?.products;

        if (products == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (products.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return MasonryGridView.count(
          cacheExtent: 5000,
          key: PageStorageKey(widget.productType),
          crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
          itemCount: products.length,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: ProductCardWidget(product: products[index]),
          ),
        );
      },
    );
  }
}