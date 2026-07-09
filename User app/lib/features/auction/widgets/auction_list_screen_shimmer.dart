import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AuctionListScreenShimmer extends StatelessWidget {
  final int itemCount;

  const AuctionListScreenShimmer({super.key, this.itemCount = 6});

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
      child: ListView.separated(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
        const SizedBox(height: Dimensions.paddingSizeDefault),
        itemBuilder: (_, __) => _AuctionListItemShimmerBody(shimmerColor: shimmerColor),
      ),
    );
  }
}

class _AuctionListItemShimmerBody extends StatelessWidget {
  final Color shimmerColor;
  const _AuctionListItemShimmerBody({required this.shimmerColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(
                          color: Theme.of(context).hintColor.withValues(alpha: .3),
                          width: 0.5,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(Dimensions.radiusDefault),
                            bottomRight: Radius.circular(Dimensions.radiusDefault),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Box(shimmerColor: shimmerColor, h: 10, w: 10, r: 2),
                            const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                            _Box(shimmerColor: shimmerColor, h: 8, w: 55, r: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _Box(shimmerColor: shimmerColor, h: 14, w: double.infinity, r: 4),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        _Box(shimmerColor: shimmerColor, h: 20, w: 20, r: 4),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Row(
                      children: [
                        _Box(shimmerColor: shimmerColor, h: 9, w: 60, r: 4),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        _Box(shimmerColor: shimmerColor, h: 12, w: 55, r: 4),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                    Row(
                      children: [
                        _Box(shimmerColor: shimmerColor, h: 9, w: 70, r: 4),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        _Box(shimmerColor: shimmerColor, h: 16, w: 65, r: 4),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                    Row(
                      children: [
                        _Box(shimmerColor: shimmerColor, h: 14, w: 14, r: 2),
                        const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                        _Box(shimmerColor: shimmerColor, h: 10, w: 24, r: 4),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        _Box(shimmerColor: shimmerColor, h: 14, w: 14, r: 2),
                        const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                        _Box(shimmerColor: shimmerColor, h: 10, w: 24, r: 4),
                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeEight,
                          ),
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusHundred),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Box(shimmerColor: shimmerColor, h: 14, w: 14, r: 2),
                              const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                              _Box(shimmerColor: shimmerColor, h: 10, w: 22, r: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          child: Container(
            height: 20,
            width: 48,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusLarge),
                bottomRight: Radius.circular(Dimensions.radiusDefault),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  final Color shimmerColor;
  final double h;
  final double w;
  final double r;

  const _Box({
    required this.shimmerColor,
    required this.h,
    required this.w,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: shimmerColor,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}