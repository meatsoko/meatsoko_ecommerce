import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AuctionShippingReturnWidget extends StatelessWidget {
  final TextEditingController shippingFeeController;
  final TextEditingController returnPolicyController;
  final bool isAiGenerating;
  final VoidCallback? onAiTap;

  const AuctionShippingReturnWidget({
    super.key,
    required this.shippingFeeController,
    required this.returnPolicyController,
    this.isAiGenerating = false,
    this.onAiTap,
  });

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashController>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1B7FED),
            offset: Offset(0, 6),
            blurRadius: 12,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x0D1B7FED),
            offset: Offset(0, -6),
            blurRadius: 12,
            spreadRadius: -3,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    getTranslated('shipping_charge_return_policy', context) ?? '',
                    style: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (splashProvider.configModel?.isAiFeatureEnabled == true && onAiTap != null)
                  InkWell(
                    onTap: onAiTap,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Icon(
                        Icons.auto_awesome,
                        size: Dimensions.iconSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Text(
              getTranslated('shipping_return_policy_description', context) ?? '',
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          _ShimmerOverlayWrapper(
            isActive: isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: .7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: .3),

            child: Column(
              children: [

                SubSectionCard(
                  helperText: getTranslated('shipping_fee_helper', context) ?? '',
                  child: AuctionTextField(
                    controller: shippingFeeController,
                    hintText: getTranslated('shipping_fee', context) ?? '',
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                SubSectionCard(
                  helperText: getTranslated('return_policy_helper', context) ?? '',
                  child: AuctionTextField(
                    controller: returnPolicyController,
                    hintText: getTranslated('return_policy', context) ?? '',
                    isRequired: true,
                    maxLength: 255,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubSectionCard extends StatelessWidget {
  final String helperText;
  final Widget child;

  const SubSectionCard({super.key, required this.helperText, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(helperText,
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          child,
        ],
      ),
    );
  }
}

class AuctionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool isRequired;
  final int? maxLength;

  const AuctionTextField({super.key, required this.controller, required this.hintText, this.keyboardType = TextInputType.text, this.isRequired = false, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      maxLength: maxLength,
      style: titilliumRegular.copyWith(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        hintText: isRequired ? '$hintText *' : hintText,
        hintStyle: titilliumRegular.copyWith(
          color: Theme.of(context).hintColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: .25),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: .25),
            width: .75,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class _ShimmerOverlayWrapper extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerOverlayWrapper({
    required this.child,
    this.isActive = false,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        child,
        if (isActive)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Shimmer.fromColors(
                baseColor: baseColor ?? Theme.of(context).primaryColor,
                highlightColor: highlightColor ?? Theme.of(context).cardColor,
                child: Container(
                  color: Theme.of(context).cardColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}