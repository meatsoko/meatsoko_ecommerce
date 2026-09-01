import 'package:flutter/material.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/features/auth/controllers/auth_controller.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/utill/images.dart';
import 'package:user_app/common/basewidget/custom_button_widget.dart';
import 'package:provider/provider.dart';

class LogoutCustomBottomSheetWidget extends StatelessWidget {
  const LogoutCustomBottomSheetWidget({super.key});

  /// Shows this confirmation using showGeneralDialog (a plain DialogRoute)
  /// rather than showModalBottomSheet. The ModalBottomSheetRoute path in this
  /// app was found to silently swallow taps on this sheet's own buttons
  /// (confirmed not caused by the button widget, the drag recognizer, or
  /// root-navigator routing — see xdocs/mobile_customization_log.md). This
  /// keeps the identical bottom-anchored slide-up visual via an explicit
  /// Align + SlideTransition instead of relying on that code path.
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: LogoutCustomBottomSheetWidget(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.only(bottom: 40, top: 15),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.paddingSizeDefault))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40,height: 4,decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha:.5), borderRadius: BorderRadius.circular(20)),
        ),
        const SizedBox(height: 30,),

       Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          child: SizedBox(width: 60,child: Image.asset(Images.exitIcon)),),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

        Text(getTranslated('sign_out', context)!, style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),

        Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeLarge),
          child: Text('${getTranslated('want_to_sign_out', context)}', style: titleRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),

        const SizedBox(height: Dimensions.paddingSizeDefault),
        Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeOverLarge),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
            Expanded(
              child: SizedBox(width: 120,child: CustomButton(buttonText: '${getTranslated('cancel', context)}',
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha:.5),
              textColor: Theme.of(context).textTheme.bodyLarge?.color,
              onTap: ()=> Navigator.pop(context),))
            ),

            const SizedBox(width: Dimensions.paddingSizeDefault,),
            Expanded(child: SizedBox(width: 120,child: CustomButton(buttonText: '${getTranslated('sign_out', context)}',
              onTap: (){
              Provider.of<AuthController>(context, listen: false).logOut().then((condition) {
                if(context.mounted) {
                  Navigator.pop(context);
                  Provider.of<AuthController>(context, listen: false).resetAllUserState(context);
                }
              });
            })
            ))
          ]))
      ],),
    );
  }
}
