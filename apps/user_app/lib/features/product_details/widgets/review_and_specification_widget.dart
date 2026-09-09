import 'package:flutter/material.dart';
import 'package:user_app/features/product_details/controllers/product_details_controller.dart';
import 'package:user_app/features/review/controllers/review_controller.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ReviewAndSpecificationSectionWidget extends StatelessWidget {
  final double? averageReview;
  const ReviewAndSpecificationSectionWidget({
    super.key,
    this.averageReview
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailsController>(
      builder: (context, productDetailsController, _) {
        final bool showReviewsTab = (averageReview ?? 0) > 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
          child: Row(children: [
            _TabLabel(
              label: getTranslated('specification', context) ?? '',
              isSelected: !productDetailsController.isReviewSelected,
              onTap: () => productDetailsController.selectReviewSection(false),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraLarge),

            if (showReviewsTab)
              Consumer<ReviewController>(
                builder: (context, reviewController, _) => _TabLabel(
                  label: '${getTranslated('reviews', context)} (${reviewController.totalReviews})',
                  isSelected: productDetailsController.isReviewSelected,
                  onTap: () => productDetailsController.selectReviewSection(true),
                ),
              ),
          ]),
        );
      }
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabLabel({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: (isSelected ? textBold : textMedium).copyWith(fontSize: Dimensions.fontSizeDefault, color: color)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 2,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ]),
      ),
    );
  }
}
