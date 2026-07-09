import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AuctionHorizontalCardShimmerWidget extends StatelessWidget {
  const AuctionHorizontalCardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color shimmerColor = isDark
        ? Theme.of(context).primaryColor.withValues(alpha: .05)
        : Theme.of(context).cardColor;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Stack(
              children: [
                // Image placeholder
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
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
                        topLeft: Radius.circular(Dimensions.radiusDefault),
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
                    height: 20,
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
          ),

          // Right: content column (Expanded, same as real widget)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Product name
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                  // Price row: label + value
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 70,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Container(
                        height: 12,
                        width: 55,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                  // Stats row: eye icon + count + gavel icon + count
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 14,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                      Container(
                        height: 10,
                        width: 24,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Container(
                        height: 10,
                        width: 14,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                      Container(
                        height: 10,
                        width: 24,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
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