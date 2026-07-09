import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:shimmer/shimmer.dart';

class AiLoadingState extends StatelessWidget {
  const AiLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              getTranslated('ai_is_generating_product_details', context) ?? 'AI is generating product details…',
              style: titleHeader.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeSmall,
              ),
              maxLines: 2,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Shimmer.fromColors(
            baseColor: Theme.of(context).primaryColor,
            highlightColor: Colors.grey[100]!,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  getTranslated('generating', context) ?? 'Generating…',
                  style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLastTab;
  final bool isLoading;

  const NextButton({
    super.key,
    this.onTap,
    this.isLastTab = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: isLoading ? Theme.of(context).primaryColor.withValues(alpha: 0.6) : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ) : Text(
              isLastTab ? getTranslated('submit', context) ?? 'Submit' : getTranslated('next', context) ?? 'Next',
              style: titilliumBold.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}