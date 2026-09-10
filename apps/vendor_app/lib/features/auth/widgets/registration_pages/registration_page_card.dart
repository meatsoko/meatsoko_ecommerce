import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/theme/controllers/theme_controller.dart';
import 'package:vendor_app/utill/dimensions.dart';
import 'package:vendor_app/utill/styles.dart';

/// Shared card shell + heading used by every registration step page, so the
/// 5-page flow reads as one continuous form instead of differently-styled
/// screens.
class RegistrationPageCard extends StatelessWidget {
  final String heading;
  final List<Widget> children;
  const RegistrationPageCard({super.key, required this.heading, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.04)),
            boxShadow: [
              BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).primaryColor.withValues(alpha:0):
              Theme.of(context).primaryColor.withValues(alpha:.10),
                offset: const Offset(0, 2.0), blurRadius: 4.0,
              )
            ]
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Align(
              alignment: Alignment.center,
              child: Text(heading, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color))
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Divider(color: Theme.of(context).primaryColor.withValues(alpha:0.04), height: 0, indent: 0, thickness: 1),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ...children,
            const SizedBox(height: 100),
          ]),
        ),
      ),
    );
  }
}
