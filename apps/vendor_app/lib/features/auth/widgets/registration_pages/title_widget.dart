import 'package:flutter/material.dart';
import 'package:vendor_app/utill/dimensions.dart';
import 'package:vendor_app/utill/styles.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final bool? isRequired;
  const TitleWidget({super.key, required this.title, this.isRequired = true});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Row(children: [
          Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
          if(isRequired ?? false)
          Text(' *', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.red)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    );
  }
}
