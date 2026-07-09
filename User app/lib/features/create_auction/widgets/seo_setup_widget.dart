import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/dropdown_decorator_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/controllers/auction_ai_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SeoSetupWidget extends StatelessWidget {
  final String? metaIndex;
  final ValueChanged<String?>? onMetaIndexChanged;
  final bool metaNoFollow;
  final ValueChanged<bool?>? onMetaNoFollowChanged;
  final bool metaNoArchive;
  final ValueChanged<bool?>? onMetaNoArchiveChanged;
  final bool metaNoImageIndex;
  final ValueChanged<bool?>? onMetaNoImageIndexChanged;
  final bool metaNoSnippet;
  final ValueChanged<bool?>? onMetaNoSnippetChanged;
  final bool metaMaxSnippet;
  final ValueChanged<bool>? onMetaMaxSnippetChanged;
  final TextEditingController metaMaxSnippetValueController;
  final bool metaMaxVideoPreview;
  final ValueChanged<bool>? onMetaMaxVideoPreviewChanged;
  final TextEditingController metaMaxVideoPreviewValueController;
  final bool metaMaxImagePreview;
  final ValueChanged<bool>? onMetaMaxImagePreviewChanged;
  final String metaMaxImagePreviewValue;
  final ValueChanged<String?>? onMetaMaxImagePreviewValueChanged;

  static const Map<String, String> _previewValueToLabel = {'0': 'None', '1': 'Standard', '2': 'Large'};

  final VoidCallback? onAiTap;
  final bool isAiGenerating;

  const SeoSetupWidget({
    super.key,
    this.metaIndex,
    this.onMetaIndexChanged,
    this.metaNoFollow = false,
    this.onMetaNoFollowChanged,
    this.metaNoArchive = false,
    this.onMetaNoArchiveChanged,
    this.metaNoImageIndex = false,
    this.onMetaNoImageIndexChanged,
    this.metaNoSnippet = false,
    this.onMetaNoSnippetChanged,
    this.metaMaxSnippet = false,
    this.onMetaMaxSnippetChanged,
    required this.metaMaxSnippetValueController,
    this.metaMaxVideoPreview = false,
    this.onMetaMaxVideoPreviewChanged,
    required this.metaMaxVideoPreviewValueController,
    this.metaMaxImagePreview = false,
    this.onMetaMaxImagePreviewChanged,
    this.metaMaxImagePreviewValue = '2',
    this.onMetaMaxImagePreviewValueChanged,
    this.onAiTap,
    this.isAiGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, 6), blurRadius: 12, spreadRadius: -3),
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, -6), blurRadius: 12, spreadRadius: -3),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        getTranslated('other_seo_setup', context) ?? '',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (aiEnabled && onAiTap != null)
                      Consumer<AuctionAiController>(
                        builder: (context, aiController, _) {
                          if (aiController.metaSeoLoading) {
                            return Shimmer.fromColors(
                              baseColor: Theme.of(context).primaryColor,
                              highlightColor: Colors.grey[100]!,
                              child: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.blue),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    getTranslated('generating', context) ?? 'Generating...',
                                    style: robotoBold.copyWith(color: Colors.blue),
                                  ),
                                ],
                              ),
                            );
                          }
                          return InkWell(
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
                          );
                        },
                      ),
                  ],
                ),

                Text(getTranslated('seo_setup_description', context) ?? '',
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                _ShimmerOverlayWrapper(
                  isActive: isAiGenerating,
                  baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  child: Column(
                    children: [
                      SizedBox(
                        child: Column(children: [
                          RadioGroup<String>(
                            groupValue: metaIndex ?? '',
                            onChanged: onMetaIndexChanged ?? (_) {},
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.25)),
                              ),
                              child: Row(children: [
                                Expanded(
                                  child: Row(children: [
                                    const Radio<String>(value: 'index'),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    Flexible(child: Text(getTranslated('index', context) ?? 'Index', style: titilliumRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: metaIndex == 'index' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodySmall?.color,
                                    ), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ]),
                                ),
                                Expanded(
                                  child: Row(children: [
                                    const Radio<String>(value: 'noindex'),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    Flexible(child: Text(getTranslated('no_index', context) ?? 'No Index', style: titilliumRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: metaIndex == 'index' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodySmall?.color,
                                    ), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ]),
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.25)),
                            ),
                            child: Column(children: [
                              Row(children: [
                                Expanded(child: MetaSeoItem(title: getTranslated('no_follow', context) ?? 'No Follow', value: metaNoFollow, onChanged: onMetaNoFollowChanged)),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(child: MetaSeoItem(title: getTranslated('no_archive', context) ?? 'No Archive', value: metaNoArchive, onChanged: onMetaNoArchiveChanged)),
                              ]),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Row(children: [
                                Expanded(child: MetaSeoItem(title: getTranslated('no_image_index', context) ?? 'No Image Index', value: metaNoImageIndex, onChanged: onMetaNoImageIndexChanged)),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(child: MetaSeoItem(title: getTranslated('no_snippet', context) ?? 'No Snippet', value: metaNoSnippet, onChanged: onMetaNoSnippetChanged)),
                              ]),
                            ]),
                          ),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      SeoToggleSection(
                        title: getTranslated('max_snippet', context) ?? 'Max Snippet',
                        subtitle: getTranslated('maximum_characters_for', context) ?? 'Maximum characters for snippet',
                        switchValue: metaMaxSnippet,
                        onSwitchChanged: onMetaMaxSnippetChanged,
                        child: metaMaxSnippet
                            ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                          child: CustomTextFieldWidget(
                            inputType: TextInputType.number,
                            controller: metaMaxSnippetValueController,
                            showBorder: true,
                            hintText: getTranslated('input_snippet_value', context),
                          ),
                        ) : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      SeoToggleSection(
                        title: getTranslated('max_video_preview', context) ?? 'Max Video Preview',
                        subtitle: getTranslated('maximum_seconds_for_the_video', context) ?? 'Maximum seconds for the video',
                        switchValue: metaMaxVideoPreview,
                        onSwitchChanged: onMetaMaxVideoPreviewChanged,
                        child: metaMaxVideoPreview
                            ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                          child: CustomTextFieldWidget(
                            inputType: TextInputType.number,
                            controller: metaMaxVideoPreviewValueController,
                            showBorder: true,
                            hintText: getTranslated('input_max_video_preview_value', context),
                          ),
                        ) : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      SeoToggleSection(
                        title: getTranslated('max_image_preview', context) ?? 'Max Image Preview',
                        subtitle: getTranslated('determine_the_maximum_size_or', context) ?? 'Determine the maximum size or resolution',
                        switchValue: metaMaxImagePreview,
                        onSwitchChanged: onMetaMaxImagePreviewChanged,
                        child: metaMaxImagePreview
                            ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                          child: DropdownDecoratorWidget(
                            child: DropdownButton<String>(
                              value: _previewValueToLabel.containsKey(metaMaxImagePreviewValue) ? metaMaxImagePreviewValue : '2',
                              icon: const Icon(Icons.keyboard_arrow_down_outlined),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: _previewValueToLabel.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style:
                                titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodySmall?.color)))).toList(),
                              onChanged: onMetaMaxImagePreviewValueChanged,
                            ),
                          ),
                        ) : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SeoToggleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final Widget child;

  const SeoToggleSection({
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onSwitchChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(subtitle, style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          FlutterSwitch(
            width: 35, height: 20, toggleSize: 20,
            value: switchValue,
            borderRadius: 20,
            activeColor: Theme.of(context).primaryColor,
            padding: 1,
            onToggle: onSwitchChanged ?? (_) {},
          ),
        ]),
        child,
      ]),
    );
  }
}

class MetaSeoItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const MetaSeoItem({super.key, required this.title, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Checkbox(value: value, onChanged: onChanged),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Flexible(
        child: Text(title,
          style: textMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            fontWeight: value ? FontWeight.bold : FontWeight.normal,
            color: value ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    ]);
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