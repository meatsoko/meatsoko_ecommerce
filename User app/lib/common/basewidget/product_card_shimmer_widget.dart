import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ProductCardShimmerWidget extends StatelessWidget {
  final double? imageHeight;

  const ProductCardShimmerWidget({super.key, this.imageHeight});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color shimmerColor = isDark
        ? Theme.of(context).primaryColor.withValues(alpha: .05)
        : Theme.of(context).cardColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use provided imageHeight for masonry, else square
        final double resolvedImageHeight = imageHeight ?? constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image placeholder
            Container(
              height: resolvedImageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusSmall),
                  topRight: Radius.circular(Dimensions.radiusSmall),
                  bottomRight: Radius.circular(Dimensions.radiusSmall),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Product name
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            // Rating row
            Row(children: [
              Container(
                height: 10, width: 60,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Container(
                height: 10, width: 40,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            // Price line
            Container(
              height: 10,
              width: constraints.maxWidth * 0.5,
              decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            // Discount row
            Row(children: [
              Container(
                height: 10, width: constraints.maxWidth * 0.35,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Container(
                height: 18, width: 36,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
            ]),
          ],
        );
      },
    );
  }
}