import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/widgets/search_filter_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/controllers/search_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_filter_dialog_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class SearchProductWidget extends StatefulWidget {

  const SearchProductWidget({super.key, });

  @override
  State<SearchProductWidget> createState() => _SearchProductWidgetState();
}

class _SearchProductWidgetState extends State<SearchProductWidget> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {

    return Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Consumer<SearchProductController>(
        builder: (context, searchProductController,_) {
          // Parent provides a bounded height, so the header stays fixed and only the
          // Expanded product list below it scrolls — regardless of how many results there are.
          return Column(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(children: [
                Expanded(child: Text('${getTranslated('product_list', context)}',style: robotoBold,)),


                InkWell(onTap: () => showModalBottomSheet(context: context,
                  isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (c) => const SearchFilterBottomSheet()),
                  child: Stack(children: [

                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(width: 20, height: 20, child: Image.asset(Images.sort,
                        color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                        Colors.white:Theme.of(context).primaryColor))
                    ),

                    if(searchProductController.isSortingApplied)
                      CircleAvatar(radius: 5, backgroundColor: Theme.of(context).primaryColor)

                    ],
                  )),
                const SizedBox(width: Dimensions.paddingSizeDefault,),


                InkWell(onTap: () => showModalBottomSheet(context: context,
                  isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (c) =>  const ProductFilterDialog(fromShop: false)),

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
                      )),
                    if(searchProductController.isFilterApplied)
                      CircleAvatar(radius: 5, backgroundColor: Theme.of(context).primaryColor,)
                    ],
                  ))])),

              const SizedBox(height: Dimensions.paddingSizeSmall),


            Expanded(child: searchProductController.searchedProduct!.products!.isNotEmpty ?
              SingleChildScrollView(
                controller: scrollController,
                child: PaginatedListView(scrollController: scrollController,
                    onPaginate: (offset) async{
                  await searchProductController.searchProduct(query: searchProductController.searchController.text, offset: offset!);
                    },
                    totalSize: searchProductController.searchedProduct?.totalSize,
                    offset: searchProductController.searchedProduct?.offset,
                    itemView: RepaintBoundary(
                      child: MasonryGridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        crossAxisCount: ResponsiveHelper.isTab(context)? 3: 2,
                        shrinkWrap: true,
                        itemCount: searchProductController.searchedProduct!.products!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.all(Dimensions.paddingSizeEight),
                            child: ProductCardWidget(product: searchProductController.searchedProduct!.products![index]),
                          );},
                      ),
                    )),
              ) : const NoInternetOrDataScreenWidget(isNoInternet: false)),


            ],
          );
        }
      ),
    );
  }
}
