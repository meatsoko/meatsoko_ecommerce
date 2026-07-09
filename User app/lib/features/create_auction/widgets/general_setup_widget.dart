import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


class GeneralSetupWidget extends StatefulWidget {
  final VoidCallback? onAiTap;
  final bool isAiGenerating;
  final String? productType;
  final List<String> productTypeList;
  final ValueChanged<String?> onProductTypeChanged;
  final String? category;
  final List<String> categoryList;
  final ValueChanged<String?> onCategoryChanged;
  final String? brand;
  final List<String> brandList;
  final ValueChanged<String?> onBrandChanged;
  final String? itemCondition;
  final ValueChanged<String?> onItemConditionChanged;
  final Map<String, String> itemConditionMap;

  const GeneralSetupWidget({
    super.key,
    this.onAiTap,
    this.isAiGenerating = false,
    this.productType,
    this.productTypeList = const [],
    required this.onProductTypeChanged,
    this.category,
    this.categoryList = const [],
    required this.onCategoryChanged,
    this.brand,
    this.brandList = const [],
    required this.onBrandChanged,
    this.itemCondition,
    required this.onItemConditionChanged,
    required this.itemConditionMap,
  });

  @override
  State<GeneralSetupWidget> createState() => _GeneralSetupWidgetState();
}

class _GeneralSetupWidgetState extends State<GeneralSetupWidget> {

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.homePagePadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(getTranslated('general_setup', context) ?? '',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true && widget.onAiTap != null)
                  InkWell(
                    onTap: widget.onAiTap,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Icon(Icons.auto_awesome, size: Dimensions.iconSizeSmall, color: Theme.of(context).primaryColor),
                    ),
                  ),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.homePagePadding),
            child: Text(getTranslated('general_setup_description', context) ?? '',
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: widget.isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // AuctionDropdownField(
                  //   hintText: getTranslated('product_type', context) ?? "",
                  //   value: widget.productType,
                  //   items: widget.productTypeList,
                  //   isEnabled: false,
                  //   onChanged: widget.onProductTypeChanged,
                  // ),
                  // const SizedBox(height: Dimensions.paddingSizeSmall),

                  AuctionDropdownField(
                    hintText: getTranslated('category', context) ?? "",
                    value: widget.category,
                    items: widget.categoryList,
                    isRequired: true,
                    onChanged: widget.onCategoryChanged,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  AuctionDropdownField(
                    hintText: getTranslated('brand', context) ?? "",
                    value: widget.brand,
                    items: widget.brandList,
                    onChanged: widget.onBrandChanged,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  AuctionDropdownField(
                    hintText: getTranslated('item_condition', context) ?? "",
                    value: widget.itemCondition,
                    items: widget.itemConditionMap.keys.toList(),
                    isRequired: true,
                    onChanged: (val) {
                      widget.onItemConditionChanged(val);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),
        ],
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
                highlightColor: highlightColor ?? Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class AuctionDropdownField extends StatelessWidget {
  final String hintText;
  final String? value;
  final List<String> items;
  final bool isEnabled;
  final bool isRequired;
  final ValueChanged<String?> onChanged;

  const AuctionDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    this.isEnabled = true,
    this.isRequired = false,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraExtraSmall,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .25), width: .75),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: isEnabled ? const Icon(Icons.keyboard_arrow_down_outlined) : const SizedBox(),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        hint: RichText(
          text: TextSpan(
            style: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
            children: [
              TextSpan(text: hintText),
              if (isRequired)
                TextSpan(text: ' *', style: titilliumRegular),
            ],
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(getTranslated(item, context) ?? '', style: titilliumRegular),
          );
        }).toList(),
        onChanged: isEnabled ? onChanged : null,
      ),
    );
  }
}