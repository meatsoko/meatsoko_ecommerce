// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ParticipationAuctionDetailsScreenShimmer extends StatelessWidget {
  const ParticipationAuctionDetailsScreenShimmer({super.key});

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
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 220, width: double.infinity, color: shimmerColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Container(height: 20, width: 180, color: shimmerColor),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(height: 16, width: 120, color: shimmerColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Container(height: 100, width: double.infinity, color: shimmerColor),
          ],
        ),
      ),
    );
  }
}
