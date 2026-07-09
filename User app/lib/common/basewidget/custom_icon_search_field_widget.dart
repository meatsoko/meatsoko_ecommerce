import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class CustomIconSearchFieldWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String prefix;
  final Function iconPressed;
  final Function(String text)? onSubmit;
  final Function? onChanged;
  final VoidCallback? onClear;
  final TextInputType? keyboardType;

  const CustomIconSearchFieldWidget({super.key,
    required this.controller,
    required this.hint,
    required this.prefix,
    required this.iconPressed,
    this.onSubmit,
    this.onChanged,
    this.onClear,
    this.keyboardType,
  });

  @override
  State<CustomIconSearchFieldWidget> createState() => _CustomSearchFieldWidgetState();
}

class _CustomSearchFieldWidgetState extends State<CustomIconSearchFieldWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            textInputAction: TextInputAction.search,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeTwelve),

              suffixIcon: InkWell(
                onTap: () {
                  if (_hasText) {
                    widget.controller?.clear();
                    widget.onClear?.call();
                  } else {
                    widget.iconPressed();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  padding: EdgeInsets.all(_hasText ? Dimensions.paddingSizeTwelve : Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: CustomAssetImageWidget(
                    _hasText ? Images.crossIcon : Images.iconsSearch,
                    color: Theme.of(context).cardColor,
                    height: 10, width: 10
                  ),
                ),
              ),
            ),
            onSubmitted: widget.onSubmit,
            onChanged: widget.onChanged as void Function(String)?,
          ),
        ),
      ),
    ]);
  }
}