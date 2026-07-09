import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/shop_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShopInfoWidget extends StatefulWidget {
  final String sellerId;
  const ShopInfoWidget({super.key, required this.sellerId});

  @override
  State<ShopInfoWidget> createState() => _ShopInfoWidgetState();
}

class _ShopInfoWidgetState extends State<ShopInfoWidget> {

  @override
  void initState() {
    Provider.of<ShopController>(context, listen: false).getSellerInfoProductDetails(widget.sellerId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final splash = Provider.of<SplashController>(context, listen: false);

    return Consumer<ShopController>(
      builder: (context, seller, child) {

        final sellerData = seller.sellerInfoModelProductDetails;
        if (sellerData == null) return const SizedBox();
        final sellerShop = sellerData.seller?.shop;
        final inHouseShop = splash.configModel?.inHouseShop;
        final bool isSeller = sellerShop != null;

        final bool isVacationActive = ShopHelper.isVacationActive(
          context, startDate: seller.sellerInfoModelProductDetails?.seller?.shop?.vacationStartDate,
          endDate: seller.sellerInfoModelProductDetails?.seller?.shop?.vacationEndDate,
          vacationDurationType: seller.sellerInfoModelProductDetails?.seller?.shop?.vacationDurationType,
          vacationStatus: seller.sellerInfoModelProductDetails?.seller?.shop?.vacationStatus,
          isInHouseSeller: widget.sellerId == '0',
        );

        return Container(
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeTwelve),
          ),

          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeEight),
                    child: CustomImageWidget(
                      image: isSeller ? sellerShop.imageFullUrl?.path ?? '' : inHouseShop?.imageFullUrl?.path ?? '',
                      height: 40,
                      width: 40,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Text(
                      isSeller ? sellerShop.name ?? '' : inHouseShop?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge!.color
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      _openShop(context, sellerData, splash);
                    },
                    child: Row(
                      children: [
                        Text(getTranslated('visit_store', context)!,
                          style: titilliumSemiBold.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),

                        Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).hintColor),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeTwelve),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).hintColor.withValues(alpha: .2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatItem(
                            title: sellerData.avgRating ?? '0',
                            subtitle: getTranslated('ratings', context)!,
                          ),

                          const VerticalDividerWidget(),

                          StatItem(
                            title: '${sellerData.totalReview ?? 0}',
                            subtitle: getTranslated('reviews', context)!,
                          ),

                          const VerticalDividerWidget(),

                          StatItem(
                            title: NumberFormat.compact().format(sellerData.totalProduct ?? 0),
                            subtitle: getTranslated('products', context)!,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeTwelve),

                  InkWell(
                    onTap: () {
                      _handleChat(context, sellerData, splash, isVacationActive);
                    },
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      child: Center(
                        child: CustomAssetImageWidget(Images.storeChatIcon, height: 20, width: 20)
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _openShop(BuildContext context, sellerData, SplashController splash) {
    if (sellerData.seller != null) {
      // print("---if");
      // print("---if--->>${sellerData.seller?.shop?.rating?.toString()}");
      RouterHelper.getTopSellerRoute(
        action: RouteAction.push,
        slug: sellerData.seller?.shop?.slug,
        sellerId: sellerData.seller?.id,
        temporaryClose: sellerData.seller?.shop?.temporaryClose ?? false,
        vacationStatus: sellerData.seller?.shop?.vacationStatus ?? false,
        vacationEndDate: sellerData.seller?.shop?.vacationEndDate,
        vacationStartDate: sellerData.seller?.shop?.vacationStartDate,
        vacationDurationType: sellerData.seller?.shop?.vacationDurationType,
        name: sellerData.seller?.shop?.name,
        banner: sellerData.seller?.shop?.bannerFullUrl?.path,
        image: sellerData.seller?.shop?.imageFullUrl?.path,
       // rating: sellerData.seller?.shop,
      );
    } else {
      RouterHelper.getTopSellerRoute(
        action: RouteAction.push,
        slug: splash.configModel?.inHouseShop?.slug,
        sellerId: 0,
        temporaryClose:
        splash.configModel?.inhouseTemporaryClose?.status ?? false,
        vacationStatus:
        splash.configModel?.inhouseVacationAdd?.status,
        vacationEndDate:
        splash.configModel?.inhouseVacationAdd?.vacationEndDate,
        vacationStartDate:
        splash.configModel?.inhouseVacationAdd?.vacationStartDate,
        vacationDurationType:
        splash.configModel?.inhouseVacationAdd?.vacationDurationType,
        name: splash.configModel?.inHouseShop?.name,
        banner: splash.configModel?.inHouseShop?.bannerFullUrl?.path,
        image: splash.configModel?.inHouseShop?.imageFullUrl?.path,
      );
    }
  }

  void _handleChat(BuildContext context, sellerData, SplashController splash, bool isVacationActive) {

    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      showModalBottomSheet(
        context: context,
        builder: (_) => NotLoggedInBottomSheetWidget(
          fromPage: RouterHelper.productDetailsScreen,
        ),
      );
      return;
    }

    if ((sellerData.seller?.shop?.temporaryClose ?? false)) {
      showCustomSnackBarWidget(getTranslated('this_shop_is_close_now', context), context, snackBarType: SnackBarType.error);
      return;
    }

    Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);

    RouterHelper.getChatScreenRoute(
      action: RouteAction.push,
      id: sellerData.seller?.id ?? 0,
      name: sellerData.seller?.shop?.name ?? splash.configModel?.inHouseShop?.name ?? '',
      userType: 1,
      image: sellerData.seller?.shop?.imageFullUrl?.path ?? splash.configModel?.inHouseShop?.imageFullUrl?.path ?? '',
      isShopOnVacation: isVacationActive,
      isShopTemporaryClosed: sellerData.seller?.shop?.temporaryClose ?? false,
    );
  }
}

class StatItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const StatItem({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
          style: titilliumSemiBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(subtitle,
          style: titleRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ],
    );
  }
}

class VerticalDividerWidget extends StatelessWidget {
  const VerticalDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).hintColor.withValues(alpha: 0.2),
    );
  }
}
