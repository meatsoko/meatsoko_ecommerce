import 'package:flutter/material.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/brand_colors.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/common/basewidget/custom_button_widget.dart';
import 'package:user_app/helper/route_healper.dart';

class NotLoggedInWidget extends StatelessWidget {
  final String? message;
  final String fromPage;
  final VoidCallback? onLoginSuccess;
  final String backPage;
  const NotLoggedInWidget({super.key, this.message, required this.fromPage, this.onLoginSuccess, this.backPage = 'home'});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Brand-themed lock badge. Replaces login_icon.png, a 6valley-blue
          // raster that clashed with the burgundy theme and couldn't adapt
          // to dark mode.
          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            child: Container(width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BrandColors.burgundy.withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 36, color: BrandColors.burgundy),
            ),),
          Text(getTranslated('please_login', context)!, style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),),

          Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeLarge),
            child: Text( message ?? '${getTranslated('need_to_login', context)}', textAlign: TextAlign.center,style:  titleRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),),

          Center(child: SizedBox(width: 160,child: CustomButton(buttonText: '${getTranslated('login', context)}',
              backgroundColor: Colors.transparent,
              isBorder: true,
              textColor: Theme.of(context).primaryColor,
              onTap: () => RouterHelper.getLoginRoute(fromPage: fromPage, onLoginSuccess: onLoginSuccess)))),

        InkWell(
          onTap: () => RouterHelper.getDashboardRoute(action: RouteAction.push, page: backPage),
          child: Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
            child: Text(getTranslated('back_to_home', context)!,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor),
            )
          ),
        ),

        ],
      ),
    );
  }
}
