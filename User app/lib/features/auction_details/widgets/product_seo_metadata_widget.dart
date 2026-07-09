import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class ProductSeoMetaDataWidget extends StatelessWidget {
  final String? seoTitle;
  final String? metaDescription;
  final String? imageUrl;

  const ProductSeoMetaDataWidget({
    super.key,
    this.seoTitle,
    this.metaDescription,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              getTranslated('product_seo_metadata', context) ?? "",
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)
          ),
          const SizedBox(height: Dimensions.paddingSizeEight),

          if (seoTitle != null && seoTitle!.isNotEmpty) ...[
            Text(seoTitle!,
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)
            ),
            const SizedBox(height: Dimensions.paddingSizeEight),
          ],

          if (metaDescription != null && metaDescription!.isNotEmpty) ...[
            Text(metaDescription!, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],

          MetaThumbnail(imageUrl: imageUrl ?? ""),
        ],
      ),
    );
  }
}

class MetaThumbnail extends StatelessWidget {
  final String imageUrl;

  const MetaThumbnail({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.paddingSizeEight),
      child: CustomImageWidget(image: imageUrl, width: 72, height: 72, fit: BoxFit.cover),
    );
  }
}
