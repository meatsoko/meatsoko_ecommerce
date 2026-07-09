import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:shimmer/shimmer.dart';

class AiIconButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const AiIconButton({super.key, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Theme.of(context).primaryColor,
        highlightColor: Colors.grey[100]!,
        child: Row(mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: Dimensions.iconSizeSmall, color: Theme.of(context).primaryColor),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              getTranslated('generating', context) ?? 'Generating...',
              style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Icon(Icons.auto_awesome, size: Dimensions.iconSizeSmall, color: Theme.of(context).primaryColor),
      ),
    );
  }
}