import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


class ProductSeoWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String? existingImageUrl;
  final XFile? image;
  final VoidCallback? onImagePick;
  final VoidCallback? onImageRemove;
  final bool isAiGenerating;
  final VoidCallback? onAiTap;

  const ProductSeoWidget({
    super.key,
    required this.nameController,
    required this.descriptionController,
    this.existingImageUrl,
    this.image,
    this.onImagePick,
    this.onImageRemove,
    this.isAiGenerating = false,
    this.onAiTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.homePagePadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(getTranslated('product_seo', context) ?? '',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true && onAiTap != null)
                  InkWell(
                    onTap: onAiTap,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Icon(
                        Icons.auto_awesome,
                        size: Dimensions.iconSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.homePagePadding),
            child: Text(getTranslated('product_seo_description', context) ?? '',
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  CustomTextFieldWidget(
                    controller: nameController,
                    hintText: getTranslated('meta_title', context) ?? "",
                    showBorder: true,
                    borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                    hintTextStyle : titleRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  CustomTextFieldWidget(
                    controller: descriptionController,
                    hintText: getTranslated('description', context) ?? "",
                    showBorder: true,
                    borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                    hintTextStyle : titleRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: Dimensions.fontSizeSmall),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getTranslated('meta_image', context) ?? "",
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            children: <InlineSpan>[
                              TextSpan(text: getTranslated('jpg_png_less_then_1_mb', context) ?? ''),

                              TextSpan(
                                text: getTranslated('ratio_1_1', context) ?? '',
                                style: TextStyle(color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        (image == null && existingImageUrl == null)
                            ? AddImageZone(onTap: onImagePick)
                            : ImagePreview(file: image, existingImageUrl: existingImageUrl, onRemove: onImageRemove),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    ),
                  ),
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAssetImageWidget(
                Images.addImageIcon,
                height: 30,
                width: 30,
                color: Theme.of(context).hintColor.withValues(alpha: .7),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                getTranslated('click_to_add', context) ?? "",
                style: textMedium.copyWith(
                  color: Theme.of(context).hintColor.withValues(alpha: .7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final XFile? file;
  final String? existingImageUrl;
  final VoidCallback? onRemove;

  const ImagePreview({
    super.key,
    this.file,
    this.existingImageUrl,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: file != null
              ? Image.file(File(file!.path), width: double.infinity, height: 150, fit: BoxFit.cover)
              : Image.network(existingImageUrl!, width: double.infinity, height: 150, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8, right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
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