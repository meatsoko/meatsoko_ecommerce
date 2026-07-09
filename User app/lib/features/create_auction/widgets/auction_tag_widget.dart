import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:textfield_tags/textfield_tags.dart';

class AuctionTagWidget extends StatefulWidget {
  final TextfieldTagsController<String>? controller;
  final List<String> initialTags;
  final ValueChanged<List<String>>? onTagsChanged;
  final String? hintText;
  final List<String> textSeparators;

  const AuctionTagWidget({
    super.key,
    this.controller,
    this.initialTags = const [],
    this.onTagsChanged,
    this.hintText,
    this.textSeparators = const [' ', ','],
  });

  @override
  State<AuctionTagWidget> createState() => _AuctionTagWidgetState();
}

class _AuctionTagWidgetState extends State<AuctionTagWidget> {
  TextfieldTagsController<String>? _internalController;
  List<String> _lastTags = const [];

  TextfieldTagsController<String> get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextfieldTagsController<String>();
    }
    _lastTags = List<String>.from(widget.initialTags);
  }

  @override
  void dispose() {
    // Only dispose the controller we created; never an externally-owned one.
    _internalController?.dispose();
    super.dispose();
  }

  void _notifyIfChanged(List<String> tags) {
    if (listEquals(_lastTags, tags)) return;
    _lastTags = List<String>.from(tags);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onTagsChanged?.call(_lastTags);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double distanceToField = MediaQuery.of(context).size.width;

    return TextFieldTags<String>(
      textfieldTagsController: _controller,
      initialTags: widget.initialTags.isNotEmpty ? widget.initialTags : const [],
      textSeparators: widget.textSeparators,
      letterCase: LetterCase.normal,
      validator: (String tag) {
        if (_controller.getTags?.contains(tag) ?? false) {
          return getTranslated('you_already_entered_that', context) ?? 'You already entered that';
        }
        return null;
      },
      inputFieldBuilder: (context, values) {
        _notifyIfChanged(values.tags);
        return TextField(
          controller: values.textEditingController,
          focusNode: values.focusNode,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              borderSide: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.15), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
            ),
            helperText: '',
            helperStyle: TextStyle(color: Theme.of(context).primaryColor),
            hintText: values.tags.isNotEmpty ? '' : (widget.hintText ?? getTranslated('enter_tag', context) ?? 'Enter tag...'),
            hintStyle: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
            errorText: values.error,
            prefixIconConstraints: BoxConstraints(maxWidth: distanceToField * 0.74),
            prefixIcon: values.tags.isNotEmpty
                ? SingleChildScrollView(
                    controller: values.tagScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: values.tags.map((String tag) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
                            color: Theme.of(context).primaryColor,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tag, style: const TextStyle(color: Colors.white)),
                              const SizedBox(width: 4.0),
                              InkWell(
                                splashColor: Colors.transparent,
                                child: const Icon(Icons.cancel, size: 14.0, color: Color.fromARGB(255, 233, 233, 233)),
                                onTap: () => values.onTagDelete(tag),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : null,
          ),
          onChanged: values.onChanged,
          onSubmitted: values.onSubmitted,
        );
      },
    );
  }
}
