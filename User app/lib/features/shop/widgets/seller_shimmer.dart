import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/store_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:shimmer/shimmer.dart';

class SellerShimmer extends StatelessWidget {
  const SellerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: ListView.separated(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 7,
          separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (_, __) => const StoreCardShimmerWidget(),
        ),
      ),
    );
  }
}