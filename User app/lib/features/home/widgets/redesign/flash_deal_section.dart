import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FlashDealSection extends StatefulWidget {
  const FlashDealSection({super.key});

  @override
  State<FlashDealSection> createState() => _FlashDealSectionState();
}

class _FlashDealSectionState extends State<FlashDealSection> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FlashDealController>(context, listen: false).getFlashDealList(false, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashDealController>(
      // selector: (_, controller) => (controller.isLoading, controller.flashDealProductOffset),
      builder: (context, flashDealController, __) {

        if (flashDealController.isLoading) {
          return Container(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            margin: const EdgeInsets.only(bottom: Dimensions.homePagePadding),
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
                  child: HomeFlashDealSectionTitle(),
                ),
                SizedBox(height: Dimensions.paddingSizeDefault),
                _FlashDealShimmer(),
              ],
            ),
          );
        }

        if (flashDealController.flashDealList.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
          margin: const EdgeInsets.only(bottom: Dimensions.homePagePadding),
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
                child: HomeFlashDealSectionTitle(),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              SizedBox(
                height: MediaQuery.sizeOf(context).shortestSide * 0.65,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  itemCount: flashDealController.flashDealList.length > AppConstants.flashDealProductShowLimit ? 11 : flashDealController.flashDealList.length,
                  itemBuilder: (context, listIndex) {
                    if (flashDealController.flashDealList.length > AppConstants.flashDealProductShowLimit &&
                        listIndex == 10) {
                      return SizedBox(
                        height: 150,
                        child: ColoredBox(
                          color: Colors.transparent,
                          child: Center(
                            child: InkWell(
                              onTap: () => RouterHelper.getFlashDealScreenViewRoute(),
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Icon(Icons.arrow_forward_ios, color: Theme.of(context).cardColor, size: Dimensions.iconSizeSmall),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox(
                      width: 150,
                      child: ProductCardWidget(product: flashDealController.flashDealList[listIndex]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HomeFlashDealSectionTitle extends StatelessWidget {
  const HomeFlashDealSectionTitle({super.key});

  String _formatUnit(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = isDark ? Colors.white : Theme.of(context).primaryColor;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

      Row(children: [
        Text(getTranslated('one_time_deal', context)!, style: titilliumBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: accentColor
        ),),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
      ],),

      Selector<FlashDealController, Duration?>(
        selector: (_, controller) => controller.duration,
        builder: (_, duration, __) {

          if (duration == null || duration.isNegative) {
            return const SizedBox.shrink();
          }

          final int days    = duration.inDays;
          final int hours   = duration.inHours.remainder(24);
          final int minutes = duration.inMinutes.remainder(60);
          final int seconds = duration.inSeconds.remainder(60);

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraSmall)),
              border: Border.all(color: accentColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("${getTranslated('ends_in', context)!} ", style: titilliumRegular.copyWith(
                  color: accentColor,
                  fontSize: Dimensions.fontSizeExtraSmall,
                ),),

                Text(
                  '${_formatUnit(days)}d : ${_formatUnit(hours)}h : ${_formatUnit(minutes)}m : ${_formatUnit(seconds)}s',
                  style: titilliumSemiBold.copyWith(
                    color: accentColor,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    ],);
  }
}

class _FlashDealShimmer extends StatelessWidget {
  const _FlashDealShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isShortMobile(context) ? 240 : 260,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: 15),
          itemCount: 5,
          separatorBuilder: (_, __) =>
          const SizedBox(width: Dimensions.paddingSizeDefault),
          itemBuilder: (_, __) => const SizedBox(
            width: 150,
            child: ProductCardShimmerWidget(),
          ),
        ),
      ),
    );
  }
}
