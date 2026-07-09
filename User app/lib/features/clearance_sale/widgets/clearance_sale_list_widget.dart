import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/clearance_sale/widgets/clearance_title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ClearanceListWidget extends StatelessWidget {
  const ClearanceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = ResponsiveHelper.isTab(context);

        final cardAspectRatio = 200 / (Platform.isIOS ? 260 : 270);
        final viewportFraction = isTablet ? 0.43 : 0.63;

        final cardWidth = screenWidth * viewportFraction;
        final reducedCardWidth = cardWidth + 5;
        final cardHeight = reducedCardWidth / cardAspectRatio;


        if (productController.clearanceProductModel == null) {
          return const Padding(
            padding: EdgeInsets.only(bottom: Dimensions.homePagePadding),
            child: FindWhatYouNeedShimmer(),
          );
        }

        final products = productController.clearanceProductModel!.products;
        if (products == null || products.isEmpty) {
          return const SizedBox();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: ClearanceTitleRowWidget(
                title: getTranslated('clearance_sale_banner', context)!,
                onTap: () {
                  RouterHelper.getClearanceSaleAllProductScreenRoute(action: RouteAction.push);
                },
              ),
            ),
            SizedBox(
              height: cardHeight,
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  viewportFraction: isTablet ? 0.405 : 0.605,
                  autoPlay: true,
                  pauseAutoPlayOnTouch: true,
                  pauseAutoPlayOnManualNavigate: true,
                  enlargeFactor: 0.3,
                  enlargeCenterPage: true,
                  pauseAutoPlayInFiniteScroll: true,
                  disableCenter: true,
                ),
                itemCount: products.length,
                itemBuilder: (context, index, _) {
                  return ProductCardWidget(product: products[index]);
                },
              ),
            ),
            const SizedBox(height: Dimensions.homePagePadding),
          ],
        );
      },
    );
  }
}

