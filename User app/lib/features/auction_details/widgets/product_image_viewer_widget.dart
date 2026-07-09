import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class ProductImageViewerWidget extends StatefulWidget {
  final List<String>? images;

  const ProductImageViewerWidget({super.key, this.images});

  @override
  State<ProductImageViewerWidget> createState() => _ProductImageViewerWidgetState();
}

class _ProductImageViewerWidgetState extends State<ProductImageViewerWidget> {
  int _selectedIndex = 0;
  late final List<String> _images;

  final CarouselSliderController _carouselSliderController = CarouselSliderController();
  final ScrollController _thumbnailScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _images = widget.images ?? List.generate(6, (_) => Images.placeholder);
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
    setState(() {
      _selectedIndex = index;
    });

    _carouselSliderController.animateToPage(index);
    _scrollThumbnailToIndex(index);
  }

  @override
  void dispose() {
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none,
      children: [
        CarouselSlider.builder(
          carouselController: _carouselSliderController,
          itemCount: _images.length,
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              child: CustomImageWidget( image: _images[index], width: double.infinity, fit: BoxFit.contain),
            );
          },
          options: CarouselOptions(
            height: 300,
            viewportFraction: 0.85,
            enableInfiniteScroll: _images.length > 1,
            autoPlay: _images.length > 1,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            scrollPhysics: _images.length > 1 ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
            onPageChanged: (index, reason) {
              setState(() => _selectedIndex = index);
              _scrollThumbnailToIndex(index);
            },
          ),
        ),

        if (_images.length > 1)
        Positioned(
          bottom: -15,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double itemWidth = 40;
                const double itemSpacing = Dimensions.paddingSizeSmall;
                const int maxVisibleCount = 5;
                final int itemCount = _images.length;

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
                                  color: _selectedIndex == i
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).hintColor.withValues(alpha: 0.3),
                                  width: _selectedIndex == i ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: CustomImageWidget(image: _images[i], fit: BoxFit.cover),
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
            )
          ),
        )
      ],
    );
  }
}