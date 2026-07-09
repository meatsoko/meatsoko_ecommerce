import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BiddingListShimmerWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const BiddingListShimmerWidget({super.key, this.itemCount = 5, this.itemHeight = 64});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color base = isDark ? Theme.of(context).primaryColor.withValues(alpha: .05) : Theme.of(context).cardColor;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      // Same fixed window as the loaded list: 4 full rows + half of the 5th.
      child: SizedBox(
        height: itemHeight * 4.5,
        child: ListView.builder(
          shrinkWrap: false,
          physics: const NeverScrollableScrollPhysics(),
          itemExtent: itemHeight,
          itemCount: itemCount,
          itemBuilder: (_, index) => _BidRowShimmer(base: base),
        ),
      ),
    );
  }
}

class _BidRowShimmer extends StatelessWidget {
  final Color base;

  const _BidRowShimmer({required this.base});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraSmall),
      child: Row(
        children: [
          _Box(color: base, height: 14, width: 20, radius: 4),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          _Box(
            color: base,
            height: Dimensions.iconSizeLarge,
            width: Dimensions.iconSizeLarge,
            radius: Dimensions.iconSizeLarge / 2,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(color: base, height: 13, width: 120, radius: 4),
                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                _Box(color: base, height: 10, width: 80, radius: 4),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _Box(color: base, height: 13, width: 60, radius: 4),
                  const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                  _Box(
                    color: base,
                    height: Dimensions.iconSizeSmall,
                    width: Dimensions.iconSizeSmall,
                    radius: Dimensions.iconSizeSmall / 2,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final Color color;
  final double height;
  final double width;
  final double radius;

  const _Box({
    required this.color,
    required this.height,
    required this.width,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}