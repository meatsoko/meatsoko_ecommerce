import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:vendor_app/features/auth/widgets/registration_pages/registration_page_card.dart';
import 'package:vendor_app/features/more/screens/html_view_screen.dart';
import 'package:vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:vendor_app/features/splash/domain/models/business_pages_model.dart';
import 'package:vendor_app/localization/language_constrants.dart';
import 'package:vendor_app/utill/dimensions.dart';
import 'package:vendor_app/utill/styles.dart';

class ReviewSubmitPage extends StatelessWidget {
  const ReviewSubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authProvider, _) {
        return RegistrationPageCard(
          heading: getTranslated('review_submit', context)!,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(label: getTranslated('first_name', context)!, value: '${authProvider.firstNameController.text} ${authProvider.lastNameController.text}'.trim()),
                    _SummaryRow(label: getTranslated('email', context)!, value: authProvider.emailController.text),
                    _SummaryRow(label: getTranslated('phone', context)!, value: '${authProvider.countryDialCode ?? ''}${authProvider.phoneController.text}'),
                    _SummaryRow(label: getTranslated('shop_name', context)!, value: authProvider.shopNameController.text, isLast: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Row(children: [
                Checkbox(
                  checkColor: Theme.of(context).colorScheme.secondaryContainer,
                  activeColor: Theme.of(context).primaryColor,
                  value: authProvider.isTermsAndCondition,
                  onChanged: authProvider.updateTermsAndCondition,
                ),
                Consumer<SplashController>(
                  builder: (context, splashController, _) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HtmlViewScreen(
                          page: _getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages),
                        )));
                      },
                      child: Row(children: [
                        Text(getTranslated('i_agree_to_your', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(getTranslated('terms_and_condition', context)!, style: robotoMedium),
                      ]),
                    );
                  },
                ),
              ]),
            ),
          ],
        );
      },
    );
  }

  BusinessPageModel? _getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    BusinessPageModel? pageModel;
    if (pagesList != null && pagesList.isNotEmpty) {
      for (var page in pagesList) {
        if (page.slug == slug) {
          pageModel = page;
        }
      }
    }
    return pageModel;
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _SummaryRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor))),
          Expanded(flex: 3, child: Text(value.isEmpty ? '-' : value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color))),
        ],
      ),
    );
  }
}
