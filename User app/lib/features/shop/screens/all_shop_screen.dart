import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/store_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/widgets/seller_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AllTopSellerScreen extends StatefulWidget {
  final String title;
  const AllTopSellerScreen({super.key, required this.title});

  @override
  State<AllTopSellerScreen> createState() => _AllTopSellerScreenState();
}

class _AllTopSellerScreenState extends State<AllTopSellerScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<ShopController>(context, listen: false).setSellerType('all', notify: false);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ShopController, String?>(
      selector: (ctx, shopController) => shopController.sellerTypeTitle,
      builder: (context, sellerTypeTitle, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).highlightColor,
          appBar: CustomAppBar(
            title: '${getTranslated(sellerTypeTitle, context)}',
            showResetIcon: true,
            reset: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: PopupMenuButton(color: Theme.of(context).cardColor, itemBuilder: (context) => [

                PopupMenuItem(value: "new", textStyle: textRegular.copyWith(color: sellerTypeTitle == 'new_seller' ? Theme.of(context).primaryColor : Theme.of(context).hintColor), child: Text(getTranslated('new_seller',context)??'', style: textRegular.copyWith(color: sellerTypeTitle == 'new_seller' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color),)),

                PopupMenuItem(value: "all", textStyle: textRegular.copyWith(color: Theme.of(context).hintColor), child: Text(getTranslated('all_seller',context)??'', style: textRegular.copyWith(color: sellerTypeTitle == 'all_seller' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color))),

                PopupMenuItem(value: "top", textStyle: textRegular.copyWith(color: Theme.of(context).hintColor), child: Text(getTranslated('top_seller',context)??'', style: textRegular.copyWith(color: sellerTypeTitle == 'top_seller' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color) )),
              ],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                    vertical:  Dimensions.paddingSizeSmall,
                  ),
                  child: Container(decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.5)),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                      width: 30, height: 30,
                      child: Center(
                        child: CustomAssetImageWidget(Images.filterIcon, width: 15, height: 15,
                          color:  Provider.of<ThemeController>(context, listen: false).darkTheme?
                          Colors.white : Theme.of(context).primaryColor,
                        ),
                      ))
                ),
                onSelected: (dynamic value) {
                  final ShopController shopController = Provider.of<ShopController>(context, listen: false);

                  shopController.setSellerType(value, notify: true);
                },
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeDefault),
            child: Consumer<ShopController>(builder: (context, topSellerProvider, child) {
              return (topSellerProvider.filteredSellerModel?.sellers?.isNotEmpty ?? false) ? PaginatedListView(
                scrollController: scrollController,
                onPaginate: (int? offset) async {
                  await topSellerProvider.getFilteredSellerList(
                    offset: offset ?? 1,
                    type: topSellerProvider.sellerType,
                    // false, offset?? 1, type : topSellerProvider.sellerType,
                  );
                },
                totalSize: topSellerProvider.filteredSellerModel?.totalSize,
                offset: topSellerProvider.filteredSellerModel?.offset,
                itemView: Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    itemCount: topSellerProvider.filteredSellerModel?.sellers?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final seller = topSellerProvider.filteredSellerModel?.sellers?[index];

                      if (seller == null) return const SizedBox();

                      return StoreCardWidget(sellerInfo: seller);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: Dimensions.paddingSizeSmall);
                    },
                  ),
                ),
              ) : (topSellerProvider.filteredSellerModel?.sellers?.isEmpty ?? false)
                  ? const SizedBox() : const SellerShimmer();

            }),
          ),
        );
      },
    );
  }
}