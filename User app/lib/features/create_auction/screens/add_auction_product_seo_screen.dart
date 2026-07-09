import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/controllers/auction_ai_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_contoller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_media_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/ai_button_widgets.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/product_seo_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/seo_setup_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AddAuctionProductSeoScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final bool isLastTab;
  final CreatorAuctionProduct? initialProduct;
  final String Function()? getProductTitle;
  final String Function()? getProductDescription;

  const AddAuctionProductSeoScreen({
    super.key,
    this.onNext,
    this.isLastTab = false,
    this.initialProduct,
    this.getProductTitle,
    this.getProductDescription,
  });

  @override
  AddAuctionProductSeoScreenState createState() => AddAuctionProductSeoScreenState();
}

class AddAuctionProductSeoScreenState extends State<AddAuctionProductSeoScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController metaTitleController = TextEditingController();
  final TextEditingController metaDescriptionController = TextEditingController();
  final TextEditingController metaMaxSnippetValueController = TextEditingController();
  final TextEditingController metaMaxVideoPreviewValueController = TextEditingController();
  String? metaIndex = 'index';
  bool metaNoFollow = false;
  bool metaNoArchive = false;
  bool metaNoImageIndex = false;
  bool metaNoSnippet = false;
  bool metaMaxSnippet = false;
  bool metaMaxVideoPreview = false;
  bool metaMaxImagePreview = false;
  String metaMaxImagePreviewValue = '2';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _registerListeners();

      final isEditMode = widget.initialProduct != null;
      final aiController = Provider.of<AuctionAiController>(context, listen: false);
      if (!isEditMode && aiController.requestTypeImage) {
        await _loadDataFromImage();
      }
    });
  }

  @override
  void didUpdateWidget(AddAuctionProductSeoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProduct == null && widget.initialProduct != null) {
      initData();
      WidgetsBinding.instance.addPostFrameCallback((_) {if (mounted) _syncAllToController();});
    }
  }

  void initData() {
    final seo = widget.initialProduct?.seoInfo;
    if (seo == null) return;

    metaTitleController.text = seo.title ?? '';
    metaDescriptionController.text = seo.description ?? '';
    metaMaxSnippetValueController.text = seo.maxSnippetValue ?? '';
    metaMaxVideoPreviewValueController.text = seo.maxVideoPreviewValue ?? '';

    setState(() {
      metaIndex = seo.index?.isNotEmpty == true ? seo.index : 'index';
      metaNoFollow = seo.noFollow == 'nofollow';
      metaNoArchive = seo.noArchive == 'noarchive';
      metaNoImageIndex = seo.noImageIndex == 'noimageindex';
      metaNoSnippet = seo.noSnippet == '1';
      metaMaxSnippet = seo.maxSnippet == '1';
      metaMaxVideoPreview = seo.maxVideoPreview == '1';
      metaMaxImagePreview = seo.maxImagePreview == '1';
      final stored = seo.maxImagePreviewValue ?? '';
      metaMaxImagePreviewValue = ['0', '1', '2'].contains(stored) ? stored : '2';
    });
  }

  void _registerListeners() {
    if (!mounted) return;
    final addAuctionProductController = Provider.of<AddAuctionProductController>(context, listen: false);

    metaTitleController.addListener(() => addAuctionProductController.updateSeoFields(metaTitle: metaTitleController.text));
    metaDescriptionController.addListener(() => addAuctionProductController.updateSeoFields(metaDescription: metaDescriptionController.text));
    metaMaxSnippetValueController.addListener(() => addAuctionProductController.updateSeoFields(metaMaxSnippetValue: metaMaxSnippetValueController.text));
    metaMaxVideoPreviewValueController.addListener(() => addAuctionProductController.updateSeoFields(metaMaxVideoPreviewValue: metaMaxVideoPreviewValueController.text));

    _syncAllToController();
  }

  void _syncAllToController() {
    if (!mounted) return;
    Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(
      metaTitle: metaTitleController.text,
      metaDescription: metaDescriptionController.text,
      metaIndex: metaIndex,
      metaNoFollow: metaNoFollow ? 'nofollow' : '0',
      metaNoArchive: metaNoArchive ? 'noarchive' : '0',
      metaNoImageIndex: metaNoImageIndex ? 'noimageindex' : '0',
      metaNoSnippet: metaNoSnippet ? '1' : '0',
      metaMaxSnippet: metaMaxSnippet ? '1' : '0',
      metaMaxSnippetValue: metaMaxSnippetValueController.text,
      metaMaxVideoPreview: metaMaxVideoPreview ? '1' : '0',
      metaMaxVideoPreviewValue: metaMaxVideoPreviewValueController.text,
      metaMaxImagePreview: metaMaxImagePreview ? '1' : '0',
      metaMaxImagePreviewValue: metaMaxImagePreviewValue,
    );
  }

  Future<void> _loadDataFromImage() async {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    final title = widget.getProductTitle?.call() ?? '';
    final description = widget.getProductDescription?.call() ?? '';

    if (title.isEmpty || description.isEmpty) return;

    await aiController.generateMetaSeoSetup(
      title: title,
      description: description,
      seoTitleController: metaTitleController,
      seoDescriptionController: metaDescriptionController,
      formInit: true,
    );

    if (mounted) {
      _applyAiSeoFields(aiController);
      aiController.setRequestType(false, willUpdate: false);
    }
  }

  @override
  void dispose() {
    metaTitleController.dispose();
    metaDescriptionController.dispose();
    metaMaxSnippetValueController.dispose();
    metaMaxVideoPreviewValueController.dispose();
    super.dispose();
  }

  void _updateAndSync(VoidCallback setStateCall, {
    String? metaIndexVal,
    String? metaNoFollowVal,
    String? metaNoArchiveVal,
    String? metaNoImageIndexVal,
    String? metaNoSnippetVal,
    String? metaMaxSnippetVal,
    String? metaMaxVideoPreviewVal,
    String? metaMaxImagePreviewVal,
    String? metaMaxImagePreviewValueVal,
  }) {
    setState(setStateCall);
    Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(
      metaIndex: metaIndexVal,
      metaNoFollow: metaNoFollowVal,
      metaNoArchive: metaNoArchiveVal,
      metaNoImageIndex: metaNoImageIndexVal,
      metaNoSnippet: metaNoSnippetVal,
      metaMaxSnippet: metaMaxSnippetVal,
      metaMaxVideoPreview: metaMaxVideoPreviewVal,
      metaMaxImagePreview: metaMaxImagePreviewVal,
      metaMaxImagePreviewValue: metaMaxImagePreviewValueVal,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediaController = Provider.of<AddAuctionProductMediaController>(context);
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true;

    return Consumer<AuctionAiController>(
        builder: (context, aiController, _) {
          return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductSeoWidget(
                    nameController: metaTitleController,
                    descriptionController: metaDescriptionController,
                    image: mediaController.effectiveSeoThumbnail,
                    existingImageUrl: mediaController.effectiveSeoThumbnailUrl,
                    onImagePick: mediaController.pickSeoThumbnail,
                    onImageRemove: mediaController.removeSeoThumbnail,
                    isAiGenerating: aiController.metaSeoLoading,
                    onAiTap: aiEnabled ? _onSeoAiTap : null,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  SeoSetupWidget(
                    metaIndex: metaIndex,
                    onMetaIndexChanged: (val) => _updateAndSync(() => metaIndex = val, metaIndexVal: val),
                    metaNoFollow: metaNoFollow,
                    onMetaNoFollowChanged: (val) => _updateAndSync(() => metaNoFollow = val == true, metaNoFollowVal: val == true ? 'nofollow' : ''),
                    metaNoArchive: metaNoArchive,
                    onMetaNoArchiveChanged: (val) => _updateAndSync(() => metaNoArchive = val == true, metaNoArchiveVal: val == true ? 'noarchive' : '0'),
                    metaNoImageIndex: metaNoImageIndex,
                    onMetaNoImageIndexChanged: (val) => _updateAndSync(() => metaNoImageIndex = val == true, metaNoImageIndexVal: val == true ? 'noimageindex' : '0'),
                    metaNoSnippet: metaNoSnippet,
                    onMetaNoSnippetChanged: (val) => _updateAndSync(() => metaNoSnippet = val == true, metaNoSnippetVal: val == true ? '1' : '0'),
                    metaMaxSnippet: metaMaxSnippet,
                    onMetaMaxSnippetChanged: (val) => _updateAndSync(() => metaMaxSnippet = val, metaMaxSnippetVal: val ? '1' : '0'),
                    metaMaxSnippetValueController: metaMaxSnippetValueController,
                    metaMaxVideoPreview: metaMaxVideoPreview,
                    onMetaMaxVideoPreviewChanged: (val) => _updateAndSync(() => metaMaxVideoPreview = val, metaMaxVideoPreviewVal: val ? '1' : '0'),
                    metaMaxVideoPreviewValueController: metaMaxVideoPreviewValueController,
                    metaMaxImagePreview: metaMaxImagePreview,
                    onMetaMaxImagePreviewChanged: (val) => _updateAndSync(() => metaMaxImagePreview = val, metaMaxImagePreviewVal: val ? '1' : '0'),
                    metaMaxImagePreviewValue: metaMaxImagePreviewValue,
                    onMetaMaxImagePreviewValueChanged: (val) {
                      if (val != null) {
                        _updateAndSync(() => metaMaxImagePreviewValue = val, metaMaxImagePreviewValueVal: val);
                      }
                    },
                    onAiTap: aiEnabled ? _onSeoAiTap : null,
                    isAiGenerating: aiController.metaSeoLoading,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),

          Consumer<AddAuctionProductController>(
            builder: (context, addProductController, _) {
              return Container(
                padding: const EdgeInsets.all(Dimensions.homePagePadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey[200]!, spreadRadius: 0.5, blurRadius: 0.3)],
                ),
                child: aiController.addProductMetaScreenLoading
                    ? const AiLoadingState()
                    : NextButton(
                  onTap: widget.onNext,
                  isLastTab: widget.isLastTab,
                  isLoading: aiController.metaSeoLoading || addProductController.isLoading,
                ),
              );
            },
          ),
        ],
      ),
    );
  });}

  Future<void> _onSeoAiTap() async {
    final title = widget.getProductTitle?.call() ?? '';
    final description = widget.getProductDescription?.call() ?? '';

    if (title.isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context, snackBarType: SnackBarType.warning);
      return;
    }
    if (description.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context) ?? 'Please enter a product description first', context, snackBarType: SnackBarType.warning);
      return;
    }

    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    await aiController.generateMetaSeoSetup(
      title: title,
      description: description,
      seoTitleController: metaTitleController,
      seoDescriptionController: metaDescriptionController,
    );
    _applyAiSeoFields(aiController);
  }
  void _applyAiSeoFields(AuctionAiController aiController) {
    final seoData = aiController.metaSeoInfo?.data?.data;
    if (seoData == null) return;
    final ctrl = Provider.of<AddAuctionProductController>(context, listen: false);

    setState(() {
      if (seoData.metaIndex?.isNotEmpty == true) { metaIndex = seoData.metaIndex; ctrl.updateSeoFields(metaIndex: seoData.metaIndex); }
      if (seoData.metaNoFollow != null) { metaNoFollow = seoData.metaNoFollow == 1; ctrl.updateSeoFields(metaNoFollow: metaNoFollow ? 'nofollow' : ''); }
      if (seoData.metaNoArchive != null) { metaNoArchive = seoData.metaNoArchive == 1; ctrl.updateSeoFields(metaNoArchive: metaNoArchive ? '1' : '0'); }
      if (seoData.metaNoImageIndex != null) { metaNoImageIndex = seoData.metaNoImageIndex == 1; ctrl.updateSeoFields(metaNoImageIndex: metaNoImageIndex ? '1' : '0'); }
      if (seoData.metaNoSnippet != null) { metaNoSnippet = seoData.metaNoSnippet == 1; ctrl.updateSeoFields(metaNoSnippet: metaNoSnippet ? '1' : '0'); }
      if (seoData.metaMaxSnippet != null) { metaMaxSnippet = seoData.metaMaxSnippet == 1; ctrl.updateSeoFields(metaMaxSnippet: metaMaxSnippet ? '1' : '0'); }
      if (seoData.metaMaxSnippetValue != null) { metaMaxSnippetValueController.text = seoData.metaMaxSnippetValue.toString(); ctrl.updateSeoFields(metaMaxSnippetValue: seoData.metaMaxSnippetValue.toString()); }
      if (seoData.metaMaxVideoPreview != null) { metaMaxVideoPreview = seoData.metaMaxVideoPreview == 1; ctrl.updateSeoFields(metaMaxVideoPreview: metaMaxVideoPreview ? '1' : '0'); }
      if (seoData.metaMaxVideoPreviewValue != null) { metaMaxVideoPreviewValueController.text = seoData.metaMaxVideoPreviewValue.toString(); ctrl.updateSeoFields(metaMaxVideoPreviewValue: seoData.metaMaxVideoPreviewValue.toString()); }
      if (seoData.metaMaxImagePreview != null) { metaMaxImagePreview = seoData.metaMaxImagePreview == 1; ctrl.updateSeoFields(metaMaxImagePreview: metaMaxImagePreview ? '1' : '0'); }
      if (seoData.metaMaxImagePreviewValue?.isNotEmpty == true) {
        const labelToValue = {'none': '0', 'standard': '1', 'large': '2'};
        final raw = seoData.metaMaxImagePreviewValue!.toLowerCase().trim();
        final resolved = labelToValue[raw] ?? (['0', '1', '2'].contains(raw) ? raw : '2');
        metaMaxImagePreviewValue = resolved;
        ctrl.updateSeoFields(metaMaxImagePreviewValue: resolved);
      }
    });
  }
}