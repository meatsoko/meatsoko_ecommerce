import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AuctionFeatureTagsWidget extends StatelessWidget {
  const AuctionFeatureTagsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final commitments = Provider.of<SplashController>(context, listen: false).configModel?.auctionCommitments?.where((c) => c.isEnabled).toList() ?? [];

    if (commitments.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(commitments.length, (index) {
          final AuctionCommitment commitment = commitments[index];
          return Padding(
            padding: EdgeInsets.only(right: index != commitments.length - 1 ? Dimensions.paddingSizeSmall : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.homePagePadding,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Row(mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImageWidget(
                    image: commitment.imageFullUrl?.path ?? '',
                    width: 20, height: 20, fit: BoxFit.contain),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text(commitment.title ?? '',
                    style: titilliumSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}