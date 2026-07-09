import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class SearchHomePageWidget extends StatelessWidget {
  final bool isFormAuction;
  final bool isCompact;
  const SearchHomePageWidget({super.key, this.isFormAuction = false, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 0 : Dimensions.paddingSizeExtraExtraSmall),
      child: Container(
        padding: isCompact
            ? const EdgeInsets.only(left: Dimensions.homePagePadding, right: Dimensions.homePagePadding, top: 12)
            : const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeSmall),
        alignment: Alignment.center,
        child: IgnorePointer(
          child: SizedBox(
            height: 60,
            child: TextFormField(
              style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  hintText: getTranslated(isFormAuction ? 'search_auction' : 'search_hint', context),
                  hintStyle: textRegular.copyWith(color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.9)),
                  suffixIcon: SizedBox(width: 50,
                    child: Row(children: [
                      Container(
                        margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        child: Image.asset(Images.search, color: Colors.white, height: Dimensions.iconSizeSmall, width: Dimensions.iconSizeSmall, fit: BoxFit.contain),
                      ),
                    ]),
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }
}
