import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/slider_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/flash_deal_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';


class FlashDealsListWidget extends StatefulWidget {
  final bool isHomeScreen;
  const FlashDealsListWidget({super.key, this.isHomeScreen = true});

  @override
  State<FlashDealsListWidget> createState() => _FlashDealsListWidgetState();
}

class _FlashDealsListWidgetState extends State<FlashDealsListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = ResponsiveHelper.isTab(context);
    final cardAspectRatio = 200 / (Platform.isIOS ? 260 : 270);
    final viewportFraction = isTablet ? 0.4 : 0.6;
    final cardWidth = screenWidth * viewportFraction;
    final cardHeight = cardWidth / cardAspectRatio;


    return widget.isHomeScreen ? Consumer<FlashDealController>(
        builder: (context, flashDealController, child) {
          return flashDealController.flashDeal != null ? flashDealController.flashDealList.isNotEmpty ?
          SizedBox(
            height: cardHeight,
            child: CarouselSlider.builder(
              options: CarouselOptions(
                viewportFraction: viewportFraction,
                autoPlay: true,
                pauseAutoPlayOnTouch: true,
                pauseAutoPlayOnManualNavigate: true,
                enlargeFactor: 0.2,
                enlargeCenterPage: true,
                pauseAutoPlayInFiniteScroll: true,
                disableCenter: true,
                onPageChanged: (index, reason) => flashDealController.setCurrentIndex(index),
              ),
              itemCount: flashDealController.flashDealList.isEmpty ? 1 : flashDealController.flashDealList.length,
              itemBuilder: (context, index, next) {
                return SliderProductWidget(product: flashDealController.flashDealList[index], isCurrentIndex: index == flashDealController.currentIndex);
              },
            ),
          ) : const SizedBox() : const FlashDealShimmer();
        }) : Consumer<FlashDealController>(
      builder: (context, flashDealController, child) {
        return flashDealController.flashDealList.isNotEmpty ?
        SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: PaginatedListView(
            scrollController: _scrollController,
            totalSize: flashDealController.flashDealProductTotalSize,
            offset: flashDealController.flashDealProductOffset,
            onPaginate: (int? offset) async {
              await flashDealController.getFlashDealProducts(offset!);
            },
            itemView: RepaintBoundary(
              child: MasonryGridView.count(
                itemCount: flashDealController.flashDealList.length,
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeEight),
                    child: ProductCardWidget(product: flashDealController.flashDealList[index]),
                  );
                },
              ),
            ),
          ),
        ) : const Center(child: CircularProgressIndicator());
      },
    );
  }
}



