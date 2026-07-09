import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class ProductAdditionalImageWidget extends StatelessWidget {
  final List<XFile> images;
  final List<String>? existingImageUrls;
  final VoidCallback? onAddTap;
  final void Function(int index)? onRemoveTap;
  final bool isAiGenerating;

  const ProductAdditionalImageWidget({
    super.key,
    required this.images,
    this.existingImageUrls,
    this.onAddTap,
    this.onRemoveTap,
    this.isAiGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    final allImages = <ImageProvider>[
      ...?existingImageUrls?.map((url) => NetworkImage(url)),
      ...images.map((file) => FileImage(File(file.path))),
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, 6), blurRadius: 12, spreadRadius: -3),
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, -6), blurRadius: 12, spreadRadius: -3),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.homePagePadding),
            child: Row(
              children: [
                Text(
                  getTranslated('product_additional_image', context) ?? '',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text('*', style: robotoBold.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeDefault)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                children: [
                  TextSpan(text: getTranslated('jpg_png_less_then_1_mb', context) ?? ''),
                  TextSpan(text: getTranslated('ratio_1_1', context) ?? '', style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  (images.isEmpty && (existingImageUrls == null || existingImageUrls!.isEmpty))
                      ? AddImageZone(onTap: onAddTap) : ImageGrid(allImages: allImages, onAddTap: onAddTap, onRemoveTap: onRemoveTap),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddImageZone extends StatelessWidget {
  final VoidCallback? onTap;
  const AddImageZone({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [4, 5],
          color: Theme.of(context).hintColor,
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAssetImageWidget(Images.addImageIcon, height: 30, width: 30, color: Theme.of(context).hintColor.withValues(alpha: .7)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(getTranslated('click_to_add', context) ?? "",
                  style: textMedium.copyWith(color: Theme.of(context).hintColor.withValues(alpha: .7))),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  final List<ImageProvider> allImages;
  final VoidCallback? onAddTap;
  final void Function(int index)? onRemoveTap;

  const ImageGrid({super.key, required this.allImages, this.onAddTap, this.onRemoveTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Dimensions.paddingSizeSmall,
      runSpacing: Dimensions.paddingSizeSmall,
      children: [
        ...List.generate(allImages.length, (index) => ImageTile(
          imageProvider: allImages[index],
          onRemove: () => onRemoveTap?.call(index),
        )),
        GestureDetector(
          onTap: onAddTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.4)),
              color: Theme.of(context).hintColor.withValues(alpha: 0.05),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Theme.of(context).hintColor.withValues(alpha: 0.7), size: 24),
                const SizedBox(height: 2),
                Text(getTranslated('add', context) ?? '', style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.titleMedium!.color)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ImageTile extends StatelessWidget {
  final ImageProvider imageProvider;
  final VoidCallback? onRemove;

  const ImageTile({super.key, required this.imageProvider, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Image(image: imageProvider, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerOverlayWrapper extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerOverlayWrapper({
    required this.child,
    this.isActive = false,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isActive)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Shimmer.fromColors(
                baseColor: baseColor ?? Theme.of(context).primaryColor,
                highlightColor: highlightColor ?? Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}