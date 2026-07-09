import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadgeWidget({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical:Dimensions.paddingSizeExtraExtraSmall),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusSmall),
          bottomRight: Radius.circular(Dimensions.radiusSmall),
        ),
      ),
      child: Center(
        child: Text(text,
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, fontWeight: FontWeight.bold, color: Colors.white)
        ),
      ),
    );
  }
}