import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/discount_tag_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/compare/controllers/compare_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/enums/preview_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/screens/product_image_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/audio_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/download_preview_file.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/image_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/pdf_preview_flutter.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/video_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
  final ScrollController _thumbnailScrollController = ScrollController();

  @override
  void dispose() {
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productModel == null) return const SizedBox();

    final productModel = widget.productModel!;
    final isDarkTheme = Provider.of<ThemeController>(context, listen: false).darkTheme;
    final productDetailsController = Provider.of<ProductDetailsController>(context, listen: false);
    final bool hasPreview = productModel.productType == 'digital' && productModel.previewFileFullUrl != null && (productModel.previewFileFullUrl?.path ?? '').isNotEmpty;

    return Stack(clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _navigateToImageScreen(context),
          child: Container(
            //height: 250,
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.marginSizeDefault),
            child: CarouselSlider.builder(
              carouselController: _carouselSliderController,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index, realIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: Stack(
                    children: [
                      CustomImageWidget(
                      image: _imageUrls[index],
                      //height: 270,
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
                  _scrollThumbnailToIndex(index);
                },
              ),
            ),
          ),
        ),

        Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              FavouriteButtonWidget(
                backgroundColor: isDarkTheme ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                productId: productModel.id,
                fromProductDetails: true,
              ),

                const SizedBox(height: Dimensions.paddingSizeSmall),
                InkWell(
                  onTap: () {
                    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                      Provider.of<CompareController>(context, listen: false).addCompareList(productModel.id!);
                    } else {
                      showModalBottomSheet(
                        backgroundColor: const Color(0x00FFFFFF),
                        context: context,
                        builder: (_) =>
                        const NotLoggedInBottomSheetWidget(),
                      );
                    }
                  },
                  child: Consumer<CompareController>(
                    builder: (context, compare, _) {
                      final bool isCompared =
                      compare.compIds.contains(productModel.id);
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCompared ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.10),
                                spreadRadius: 0,
                                blurRadius: 15,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: Image.asset(Images.compare,
                              color: isCompared ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              InkWell(
                onTap: () {
                  if (productDetailsController.sharableLink != null) {
                    SharePlus.instance.share(ShareParams(text: productDetailsController.sharableLink!));
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.10),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Image.asset(Images.share, color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
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

        if (_imageUrls.length > 1)
          Positioned(
            bottom: -5,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double itemWidth = 40;
                  const double itemSpacing = Dimensions.paddingSizeSmall;
                  const int maxVisibleCount = 5;
                  final int itemCount = _imageUrls.length;
                  final double maxContainerWidth = (itemWidth * maxVisibleCount) + (itemSpacing * (maxVisibleCount - 1)) + (Dimensions.paddingSizeSmall * 2);

                  return Container(
                    width: itemCount <= maxVisibleCount ? null : maxContainerWidth,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: SingleChildScrollView(
                      controller: _thumbnailScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: itemCount <= maxVisibleCount ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                      child: Row(mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < itemCount; i++) ...[
                            GestureDetector(
                              onTap: () => _onThumbnailTap(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: itemWidth,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  border: Border.all(
                                    color: _selectedIndex == i ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor.withValues(alpha: 0.3),
                                    width: _selectedIndex == i ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  child: CustomImageWidget(image: _imageUrls[i], fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            if (i != itemCount - 1) const SizedBox(width: itemSpacing),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  List<String> get _imageUrls {
    final fullUrls = widget.productModel?.imagesFullUrl;
    if (fullUrls == null || fullUrls.isEmpty) {
      return [Images.placeholder];
    }
    final paths = fullUrls.map((img) => img.path ?? '').where((path) => path.isNotEmpty).toList();
    return paths.isEmpty ? [Images.placeholder] : paths;
  }

  void _scrollThumbnailToIndex(int index) {
    const double itemWidth = 40;
    const double itemSpacing = Dimensions.paddingSizeSmall;
    const double totalItemWidth = itemWidth + itemSpacing;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double offset = (index * totalItemWidth) - (screenWidth / 2) + (totalItemWidth / 2);

    _thumbnailScrollController.animateTo(
      offset.clamp(0.0, _thumbnailScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onThumbnailTap(int index) {
    setState(() => _selectedIndex = index);
    _carouselSliderController.animateToPage(index);
    _scrollThumbnailToIndex(index);
  }

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