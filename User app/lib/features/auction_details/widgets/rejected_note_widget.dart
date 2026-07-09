import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class RejectedNoteWidget extends StatelessWidget {
  final String note;

  const RejectedNoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getTranslated('rejected_note', context) ?? "",
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
              padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              child: Text(note, style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error.withValues(alpha: 0.50)))
            )
          ],
        ),
      ),
    );
  }
}
