import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class UploadTrackingUrlWidget extends StatefulWidget {
  final String? initialUrl;
  final String? tooltipMessage;
  final Future<bool> Function(String url)? onSave;

  const UploadTrackingUrlWidget({super.key, this.initialUrl, this.tooltipMessage, this.onSave,});

  @override
  State<UploadTrackingUrlWidget> createState() => _UploadTrackingUrlWidgetState();
}

class _UploadTrackingUrlWidgetState extends State<UploadTrackingUrlWidget> {
  late final TextEditingController _controller;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;

    final normalizedUrl = url.startsWith('http://') || url.startsWith('https://') ? url : 'https://$url';
    final uri = Uri.tryParse(normalizedUrl);
    return uri != null && uri.host.isNotEmpty && uri.host.contains('.') && !uri.host.startsWith('.') && !uri.host.endsWith('.');
  }

  Future<void> _onSave() async {
    final url = _controller.text.trim();

    if (!_isValidUrl(url)) {
      setState(() => _error = getTranslated('enter_valid_url', context) ?? 'Enter a valid URL');
      return;
    }

    setState(() {
      _error = null;
      _isSaving = true;
    });

    final success = await widget.onSave?.call(url) ?? false;

    if (mounted) {
      setState(() => _isSaving = false);
      if (!success) {
        setState(() => _error = getTranslated('failed_to_save_tracking_url', context) ?? 'Failed to save. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(getTranslated('upload_tracking_url', context) ?? "",
                style: titilliumSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                content: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Text(widget.tooltipMessage ?? getTranslated('paste_shipment_tracking_url', context) ?? "",
                    style: textRegular.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(Icons.info_outline_rounded, size: Dimensions.iconSizeDefault, color: Colors.grey.shade500),
              ),
            ],
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.url,
                  onChanged: (value) {
                    final url = value.trim();
                    final error = url.isEmpty || _isValidUrl(url) ? null : (getTranslated('enter_valid_url', context) ?? 'Enter a valid URL');
                    if (error != _error) setState(() => _error = error);
                  },
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: theme.textTheme.bodyLarge!.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'https://',
                    hintStyle: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.grey.shade400,
                    ),
                    errorText: _error,
                    errorStyle: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Colors.red,
                    ),
                    errorMaxLines: 2,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.cardColor,
                    disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                  ),
                  child: _isSaving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.cardColor),
                      )
                    : Text(widget.initialUrl != null ? getTranslated('update', context) ?? "" : getTranslated('save', context) ?? "",
                        style: titilliumSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: theme.cardColor,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}