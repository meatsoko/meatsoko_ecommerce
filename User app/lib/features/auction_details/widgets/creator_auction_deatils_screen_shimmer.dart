import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CreatorAuctionDetailsScreenShimmer extends StatelessWidget {
  const CreatorAuctionDetailsScreenShimmer({super.key});

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
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // AuctionDetailInfoWidget
                Padding(
                  padding: const EdgeInsets.all(Dimensions.radiusDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              _ShimmerBox(
                                shimmerColor: shimmerColor,
                                height: 90,
                                width: 90,
                                radius: Dimensions.paddingSizeExtraSmall,
                              ),
                              Positioned(
                                bottom: 0,
                                child: _ShimmerBox(
                                  shimmerColor: shimmerColor.withValues(alpha: .5),
                                  height: 18,
                                  width: 90,
                                  radius: 0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          // Product name, brand|category & condition
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: double.infinity, radius: 4),
                                const SizedBox(height: 6),
                                _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 160, radius: 4),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Row(
                                  children: [
                                    _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 70, radius: 4),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 8, radius: 2),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 80, radius: 4),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                                _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 90, radius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 110, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      ...List.generate(5, (_) => Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: double.infinity, radius: 4),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              flex: 3,
                              child: _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: double.infinity, radius: 4),
                            ),
                          ],
                        ),
                      )),

                      Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: double.infinity, radius: 4),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              flex: 3,
                              child: Wrap(
                                spacing: Dimensions.paddingSizeExtraSmall,
                                runSpacing: Dimensions.paddingSizeExtraSmall,
                                children: [
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 90, radius: 4),
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 70, radius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 100, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 120, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 240, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 100, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 180, radius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // AuctionProductDetailsWidget
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 130, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 16, width: 200, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      ...List.generate(4, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                        child: _ShimmerBox(
                          shimmerColor: shimmerColor,
                          height: 10,
                          width: i == 3 ? 180 : double.infinity,
                          radius: 4,
                        ),
                      )),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(
                        shimmerColor: shimmerColor,
                        height: 120,
                        width: double.infinity,
                        radius: Dimensions.radiusDefault,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // ProductSeoMetaDataWidget
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 160, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 200, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeEight),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: double.infinity, radius: 4),
                      const SizedBox(height: 4),
                      _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 220, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(
                        shimmerColor: shimmerColor,
                        height: 72,
                        width: 72,
                        radius: Dimensions.paddingSizeEight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // AuctionTimelineWidget
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 130, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      ...List.generate(2, (i) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeTwelve),
                          _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 140, radius: 4),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 200, radius: 4),
                          const SizedBox(height: Dimensions.paddingSizeTwelve),
                          if (i == 0)
                            _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                        ],
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final Color shimmerColor;
  final double height;
  final double width;
  final double radius;

  const _ShimmerBox({
    required this.shimmerColor,
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
        color: shimmerColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}