import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:user_app/common/basewidget/custom_image_widget.dart';
import 'package:user_app/common/basewidget/discount_tag_widget.dart';
// import 'package:user_app/common/basewidget/not_logged_in_bottom_sheet_widget.dart'; // only used by the disabled compare button below
// import 'package:user_app/features/compare/controllers/compare_controller.dart'; // only used by the disabled compare button below
import 'package:user_app/features/product_details/controllers/product_details_controller.dart';
import 'package:user_app/features/product_details/domain/models/product_details_model.dart';
import 'package:user_app/features/product_details/enums/preview_type.dart';
import 'package:user_app/features/product_details/screens/product_image_screen.dart';
import 'package:user_app/features/product_details/widgets/audio_preview.dart';
import 'package:user_app/features/product_details/widgets/download_preview_file.dart';
import 'package:user_app/features/product_details/widgets/image_preview.dart';
import 'package:user_app/features/product_details/widgets/pdf_preview_flutter.dart';
import 'package:user_app/features/product_details/widgets/video_preview.dart';
// import 'package:user_app/features/auth/controllers/auth_controller.dart'; // only used by the disabled compare button below
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// Reference-design adoption, latest pass (matching a food-app "Details"
// reference): plain hero image, dot pagination indicators underneath, no
// chrome on the image itself — back button and heart are page-level now
// (see product_details_screen.dart's app bar).
//
// Changed across the two redesign passes this file has been through:
//  - Favorite/compare/share used to be three icon buttons floating over
//    the top right of the hero image. Favorite is now in the app bar;
//    compare is disabled; share moved to `ProductUtilityIconsRow` below,
//    used inline near the title. Not deleted — the original block is
//    commented out at the bottom of this file's state class for reference.
//  - The thumbnail strip (small tappable square previews below the image)
//    is disabled in favor of simple dot indicators, matching this
//    reference exactly — see `_buildDotIndicators` vs. the disabled
//    `_buildThumbnailRow`.
class ProductCarouselImageViewerWidget extends StatefulWidget {
  final ProductDetailsModel? productModel;
  final bool fromFlashDeals;

  const ProductCarouselImageViewerWidget({
    super.key,
    required this.productModel,
    required this.fromFlashDeals,
  });

  @override
  State<ProductCarouselImageViewerWidget> createState() => _ProductCarouselImageViewerWidgetState();
}

class _ProductCarouselImageViewerWidgetState extends State<ProductCarouselImageViewerWidget> {
  int _selectedIndex = 0;

  final CarouselSliderController _carouselSliderController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.productModel == null) return const SizedBox();

    final productModel = widget.productModel!;
    final bool hasPreview = productModel.productType == 'digital' && productModel.previewFileFullUrl != null && (productModel.previewFileFullUrl?.path ?? '').isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _navigateToImageScreen(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.marginSizeDefault),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CarouselSlider.builder(
                  carouselController: _carouselSliderController,
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index, realIndex) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      child: Stack(
                        children: [
                          CustomImageWidget(
                          image: _imageUrls[index],
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),

                        if (widget.fromFlashDeals)
                           Positioned(
                              top: 10,
                              left: 10,
                              child: Image.asset(Images.flashDeal, scale: 2),
                            ),

                        if ((productModel.discount ?? 0) > 0 || productModel.clearanceSale != null)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: DiscountTagDetailsWidget(
                                productModel: productModel,
                                positionedTop: 0,
                                topLeftBorderRadius: Dimensions.radiusDefault,
                                bottomRightBorderRadius: Dimensions.radiusDefault,
                              ),
                            ),
                        ]
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 0.85,
                    enableInfiniteScroll: _imageUrls.length > 1,
                    autoPlay: _imageUrls.length > 1,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                    const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.easeInOut,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.2,
                    scrollPhysics: _imageUrls.length > 1 ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                    onPageChanged: (index, reason) {
                      setState(() => _selectedIndex = index);
                    },
                  ),
                ),

                if (hasPreview)
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: InkWell(
                      onTap: () => _showPreview(
                        productModel.previewFileFullUrl!.path ?? '',
                        productModel.name ?? '',
                        productModel.previewFileFullUrl!.key ?? '',
                        context,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        height: 35,
                        width: 81,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D1B7FED),
                              offset: Offset(0, 6),
                              blurRadius: 12,
                              spreadRadius: -3,
                            ),
                            BoxShadow(
                              color: Color(0x0D1B7FED),
                              offset: Offset(0, -6),
                              blurRadius: 12,
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(Images.previewEyeIcon, width: 15),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Text('${getTranslated('preview', context)}', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (_imageUrls.length > 1) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _buildDotIndicators(context),
        ],

        // ------------------------------------------------------------------
        // Disabled: the old floating favorite/compare/share icon stack that
        // used to sit at Positioned(top: 16, right: 16) over the hero image.
        // Kept here rather than deleted — favorite now lives in
        // ProductTitleWidget's price row, compare/share now live in
        // ProductUtilityIconsRow (bottom of this file), used inline near
        // the title.
        //
        // Positioned(
        //   top: 16,
        //   right: 16,
        //   child: Row(
        //     children: [
        //       FavouriteButtonWidget(
        //         backgroundColor: isDarkTheme ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
        //         productId: productModel.id,
        //         fromProductDetails: true,
        //       ),
        //       const SizedBox(height: Dimensions.paddingSizeSmall),
        //       InkWell(
        //         onTap: () { ... addCompareList ... },
        //         child: Consumer<CompareController>(builder: (context, compare, _) { ... }),
        //       ),
        //       const SizedBox(height: Dimensions.paddingSizeSmall),
        //       InkWell(
        //         onTap: () { ... share ... },
        //         child: Container(...),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  // Dot pagination indicators (reference design) — small circles below the
  // image, active one colored, tap-to-jump via the same carousel controller
  // the thumbnail row used to use.
  Widget _buildDotIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_imageUrls.length, (i) {
        final bool isSelected = _selectedIndex == i;
        return GestureDetector(
          onTap: () => _carouselSliderController.animateToPage(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }

  /// ------------------------------------------------------------------
  /// Disabled: the tappable square thumbnail strip this replaced. Kept
  /// for reference, not deleted — also disabled along with it:
  /// `_scrollThumbnailToIndex` and `_onThumbnailTap` below, and the
  /// `_thumbnailScrollController` field this used to need (removed from
  /// the state class above).
  // Widget _buildThumbnailRow(BuildContext context) {
  //   const double itemWidth = 56;
  //   const double itemSpacing = Dimensions.paddingSizeSmall;
  //   final int itemCount = _imageUrls.length;
  //
  //   return SizedBox(
  //     height: itemWidth,
  //     child: ListView.separated(
  //       controller: _thumbnailScrollController,
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
  //       physics: const BouncingScrollPhysics(),
  //       itemCount: itemCount,
  //       separatorBuilder: (_, __) => const SizedBox(width: itemSpacing),
  //       itemBuilder: (context, i) {
  //         final bool isSelected = _selectedIndex == i;
  //         return GestureDetector(
  //           onTap: () => _onThumbnailTap(i),
  //           child: AnimatedContainer(
  //             duration: const Duration(milliseconds: 200),
  //             width: itemWidth,
  //             height: itemWidth,
  //             padding: const EdgeInsets.all(2),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
  //               border: Border.all(
  //                 color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.25),
  //                 width: isSelected ? 2 : 1,
  //               ),
  //             ),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(Dimensions.radiusDefault - 2),
  //               child: CustomImageWidget(image: _imageUrls[i], fit: BoxFit.cover),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  List<String> get _imageUrls {
    final fullUrls = widget.productModel?.imagesFullUrl;
    if (fullUrls == null || fullUrls.isEmpty) {
      return [Images.placeholder];
    }
    final paths = fullUrls.map((img) => img.path ?? '').where((path) => path.isNotEmpty).toList();
    return paths.isEmpty ? [Images.placeholder] : paths;
  }

  // Disabled along with _buildThumbnailRow above (the thumbnail strip these
  // scrolled/synced) — dots don't need scroll-into-view logic.
  // void _scrollThumbnailToIndex(int index) {
  //   const double itemWidth = 56;
  //   const double itemSpacing = Dimensions.paddingSizeSmall;
  //   const double totalItemWidth = itemWidth + itemSpacing;
  //
  //   final double screenWidth = MediaQuery.of(context).size.width;
  //   final double offset = (index * totalItemWidth) - (screenWidth / 2) + (totalItemWidth / 2);
  //
  //   if (!_thumbnailScrollController.hasClients) return;
  //   _thumbnailScrollController.animateTo(
  //     offset.clamp(0.0, _thumbnailScrollController.position.maxScrollExtent),
  //     duration: const Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  // }
  //
  // void _onThumbnailTap(int index) {
  //   setState(() => _selectedIndex = index);
  //   _carouselSliderController.animateToPage(index);
  //   _scrollThumbnailToIndex(index);
  // }

  void _navigateToImageScreen(BuildContext context) {
    if (widget.productModel == null || (widget.productModel!.productImagesNull ?? true)) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductImageScreen(
          title: getTranslated('product_image', context),
          imageList: widget.productModel!.imagesFullUrl,
        ),
      ),
    );
  }

  void _showPreview(String url, String productName, String fileName, BuildContext context) {
    final PreviewType type = Provider.of<ProductDetailsController>(context, listen: false).getFileType(url);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          insetPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: switch (type) {
            PreviewType.pdf   => PdfPreview(url: url, fileName: productName),
            PreviewType.image => ImagePreview(url: url, fileName: productName),
            PreviewType.video => VideoPreview(url: url, fileName: productName),
            PreviewType.audio => AudioPreview(url: url, fileName: productName),
            PreviewType.others => DownloadPreview(url: url, fileName: fileName),
          },
        );
      },
    );
  }
}

/// Compare + share, extracted from the icon stack that used to float over
/// the hero image (see the comment in the state class above) so they can be
/// placed inline near the title instead — same interactions, same
/// controllers, just relocated.
///
/// Currently unused: the share button (compare was already disabled) was
/// removed from the title row per user request — kept defined here rather
/// than deleted, in case share is wanted back in some form later.
class ProductUtilityIconsRow extends StatelessWidget {
  final ProductDetailsModel productModel;
  const ProductUtilityIconsRow({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      // Disabled (keep-it-minimal pass): side-by-side spec comparison is a
      // weaker fit for a meat marketplace than for e.g. electronics. Kept
      // for reference, not deleted.
      // InkWell(
      //   borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      //   onTap: () {
      //     if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      //       Provider.of<CompareController>(context, listen: false).addCompareList(productModel.id!);
      //     } else {
      //       showModalBottomSheet(
      //         backgroundColor: const Color(0x00FFFFFF),
      //         context: context,
      //         builder: (_) => const NotLoggedInBottomSheetWidget(),
      //       );
      //     }
      //   },
      //   child: Consumer<CompareController>(
      //     builder: (context, compare, _) {
      //       final bool isCompared = compare.compIds.contains(productModel.id);
      //       return Padding(
      //         padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      //         child: Image.asset(Images.compare, width: 20, height: 20,
      //           color: isCompared ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
      //         ),
      //       );
      //     },
      //   ),
      // ),
      // const SizedBox(width: Dimensions.paddingSizeSmall),

      InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        onTap: () {
          final link = Provider.of<ProductDetailsController>(context, listen: false).sharableLink;
          if (link != null) {
            SharePlus.instance.share(ShareParams(text: link));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: Image.asset(Images.share, width: 20, height: 20, color: Theme.of(context).hintColor),
        ),
      ),
    ]);
  }
}
