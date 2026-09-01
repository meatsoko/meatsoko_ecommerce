import 'package:flutter/material.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';

class HomeTitleWidget extends StatelessWidget {
  final String title;
  final bool isShowViewAll;
  final VoidCallback? onViewAllTap;

  const HomeTitleWidget({super.key, required this.title, this.isShowViewAll = true, this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: Dimensions.homePagePadding),
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
        ),
      ),

      isShowViewAll ? InkWell(
        onTap: onViewAllTap,
        child: Text(getTranslated('VIEW_ALL', context) ?? '', style: titilliumRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        )),
      ): const SizedBox.shrink(),
    ]);
  }
}