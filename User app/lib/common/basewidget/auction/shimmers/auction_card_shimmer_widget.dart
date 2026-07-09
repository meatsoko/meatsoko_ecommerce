import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AuctionCardShimmerWidget extends StatelessWidget {
  final double? imageHeight;

  const AuctionCardShimmerWidget({super.key, this.imageHeight});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color shimmerColor = isDark
        ? Theme.of(context).primaryColor.withValues(alpha: .05)
        : Theme.of(context).cardColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double resolvedImageHeight = imageHeight ?? constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Image placeholder
                Container(
                  height: resolvedImageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),

                // Status badge (top-left)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: 20,
                    width: 48,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radiusSmall),
                        bottomRight: Radius.circular(Dimensions.radiusSmall),
                      ),
                    ),
                  ),
                ),

                // Timer bar (bottom)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(Dimensions.radiusSmall),
                        bottomRight: Radius.circular(Dimensions.radiusSmall),
                      ),
                    ),
                  ),
                ),
              ],
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

            // Price row
            Row(children: [
              Container(
                height: 10, width: 60,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
              Container(
                height: 10, width: 48,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            // Stats row
            Row(children: [
              Container(
                height: 10, width: 14,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
              Container(
                height: 10, width: 24,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Container(
                height: 10, width: 14,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
              Container(
                height: 10, width: 24,
                decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
              ),
            ]),
          ],
        );
      },
    );
  }
}