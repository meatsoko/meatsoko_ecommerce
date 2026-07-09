import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/controllers/auction_ai_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/ai_icon_button.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/auction_title_description_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BasicSetupWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isAiGenerating;
  final VoidCallback? onAiTap;
  final String langCode;

  final XFile? thumbnailFile;
  final String? existingThumbnailUrl;
  final VoidCallback? onThumbnailTap;
  final VoidCallback? onThumbnailRemove;

  final List<TextEditingController>? titleControllerList;
  final List<TextEditingController>? descriptionControllerList;
  final TabController? tabController;

  const BasicSetupWidget({
    super.key,
    required this.nameController,
    required this.descriptionController,
    this.isAiGenerating = false,
    this.onAiTap,
    this.langCode = 'en',
    this.thumbnailFile,
    this.existingThumbnailUrl,
    this.onThumbnailTap,
    this.onThumbnailRemove,
    this.titleControllerList,
    this.descriptionControllerList,
    this.tabController,
  });

  @override
  State<BasicSetupWidget> createState() => _BasicSetupWidgetState();
}

class _BasicSetupWidgetState extends State<BasicSetupWidget> with TickerProviderStateMixin {

  void _onTitleAiTap(AuctionAiController aiController) {
    if (widget.nameController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context);
      return;
    }
    aiController.generateAuctionTitle(
      title: widget.nameController.text.trim(),
      nameController: widget.nameController,
      langCode: widget.langCode,
    );
  }

  void _onDescriptionAiTap(AuctionAiController aiController) {
    if (widget.nameController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context);
      return;
    }
    aiController.generateAuctionDescription(
      title: widget.nameController.text.trim(),
      descriptionController: widget.descriptionController,
      langCode: widget.langCode,
    );
  }

  List<Widget> _generateTabChildren() {
    List<Widget> tabs = [];
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.language ?? [];
    for (int index = 0; index < languages.length; index++) {
      final rawName = languages[index].name ?? 'Language';
      final name = rawName.isEmpty ? rawName : '${rawName[0].toUpperCase()}${rawName.substring(1)}';
      tabs.add(Text(name, style: robotoBold.copyWith()));
    }
    return tabs;
  }

  List<Widget> _generateTabPage(TabController? tabController) {
    List<Widget> tabView = [];
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.language ?? [];
    final titleList = widget.titleControllerList ?? [];
    final descList = widget.descriptionControllerList ?? [];

    for (int index = 0; index < languages.length; index++) {
      tabView.add(
        AuctionTitleDescriptionWidget(
          titleControllerList: titleList,
          descriptionControllerList: descList,
          index: index,
          langCode: languages[tabController?.index ?? 0].code ?? 'en',
          isRequired: index == 0,
        ),
      );
    }
    return tabView;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = widget.thumbnailFile != null ? FileImage(File(widget.thumbnailFile!.path)) as ImageProvider : (widget.existingThumbnailUrl != null ? NetworkImage(widget.existingThumbnailUrl!) : null);
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true;
    final bool isMultiLanguage = widget.titleControllerList != null && widget.descriptionControllerList != null;

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.fontSizeExtraLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(getTranslated('basic_setup', context) ?? '',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true && widget.onAiTap != null)
                  InkWell(
                    onTap: widget.onAiTap,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Icon(Icons.auto_awesome, size: Dimensions.iconSizeSmall, color: Theme.of(context).primaryColor),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.fontSizeExtraLarge),
            child: Text(getTranslated('basic_setup_description', context) ?? '',
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: widget.isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeEight),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  if (isMultiLanguage)
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeDefault,
                                    left: Dimensions.paddingSizeEight,
                                    bottom: Dimensions.paddingSizeEight,
                                  ),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: TabBar(
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      tabAlignment: TabAlignment.start,
                                      isScrollable: true,
                                      dividerColor: Theme.of(context).hintColor,
                                      controller: widget.tabController,
                                      indicatorColor: Theme.of(context).primaryColor,
                                      indicatorWeight: 12,
                                      labelColor: Theme.of(context).primaryColor,
                                      indicator: UnderlineTabIndicator(
                                        borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
                                        insets: EdgeInsets.zero,
                                      ),
                                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
                                      unselectedLabelStyle: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
                                      labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                                      tabs: _generateTabChildren(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 245,
                                child: AnimatedBuilder(
                                  animation: widget.tabController ?? TabController(length: 1, vsync: this),
                                  builder: (BuildContext context, Widget? child) {
                                    return TabBarView(
                                      controller: widget.tabController,
                                      children: _generateTabPage(widget.tabController),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Consumer<AuctionAiController>(
                        builder: (context, aiController, _) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (aiEnabled)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: AiIconButton(
                                    isLoading: aiController.titleLoading,
                                    onTap: () => _onTitleAiTap(aiController),
                                  ),
                                ),

                              CustomTextFieldWidget(
                                controller: widget.nameController,
                                hintText: getTranslated('product_name', context) ?? 'Type Product Name',
                                showBorder: true,
                                borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeTwelve),

                              if (aiEnabled)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: AiIconButton(
                                    isLoading: aiController.descLoading,
                                    onTap: () => _onDescriptionAiTap(aiController),
                                  ),
                                ),

                              CustomTextFieldWidget(
                                controller: widget.descriptionController,
                                hintText: getTranslated('product_description', context) ?? 'Description',
                                borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                                maxLines: 3,
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(getTranslated('upload_thumbnail', context) ?? "",
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text('*', style: robotoBold.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeDefault)),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                            children: [
                              TextSpan(text: getTranslated('jpg_png_less_then_1_mb', context) ?? ''),
                              TextSpan(text: getTranslated('ratio_1_1', context) ?? '', style: TextStyle(color: Theme.of(context).hintColor)),
                            ],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        imageProvider != null
                            ? ThumbnailPreview(imageProvider: imageProvider, onRemove: widget.onThumbnailRemove)
                            : ThumbnailPickerZone(onTap: widget.onThumbnailTap),

                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThumbnailPickerZone extends StatelessWidget {
  final VoidCallback? onTap;
  const ThumbnailPickerZone({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [4, 5],
          color: Theme.of(context).hintColor,
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAssetImageWidget(Images.addImageIcon, height: 30, width: 30, color: Theme.of(context).hintColor.withValues(alpha: .7)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(getTranslated('click_to_add', context) ?? "",
                  style: textMedium.copyWith(color: Theme.of(context).hintColor.withValues(alpha: .7))),
            ],
          ),
        ),
      ),
    );
  }
}

class ThumbnailPreview extends StatelessWidget {
  final ImageProvider imageProvider;
  final VoidCallback? onRemove;

  const ThumbnailPreview({super.key, required this.imageProvider, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Image(
            image: imageProvider,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: Dimensions.paddingSizeExtraSmall,
          right: Dimensions.paddingSizeExtraSmall,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: Theme.of(context).cardColor),
            ),
          ),
        ),
      ],
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