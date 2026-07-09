import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class StoreCardShimmerWidget extends StatelessWidget {
  const StoreCardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color shimmerColor = isDark
        ? Theme.of(context).primaryColor.withValues(alpha: .05)
        : Theme.of(context).cardColor;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusSmall),
                topRight: Radius.circular(Dimensions.radiusSmall),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40, width: 40,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 10, width: double.infinity,
                            decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                          Row(children: [
                            Container(
                              height: 10, width: 10,
                              decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                            Container(
                              height: 10, width: 30,
                              decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(height: 1, color: shimmerColor),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        height: 12, width: 12,
                        decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Container(
                        height: 10, width: 60,
                        decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
                      ),
                    ]),
                    Container(
                      height: 10, width: 45,
                      decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}