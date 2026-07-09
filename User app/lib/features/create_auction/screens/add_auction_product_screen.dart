import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/controllers/auction_ai_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/widgets/auction_ai_generator_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_media_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/ai_button_widgets.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/auction_product_video_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/auction_shipping_return_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/basic_setup_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/general_setup_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/product_additional_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';


class AddAuctionProductScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final CreatorAuctionProduct? initialProduct;
  const AddAuctionProductScreen({super.key, this.onNext, this.initialProduct});

  @override
  AddAuctionProductScreenState createState() => AddAuctionProductScreenState();
}

class AddAuctionProductScreenState extends State<AddAuctionProductScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  TabController? _tabController;
  bool _loadDataFromImageCalled = false;


  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController shippingFeeController = TextEditingController();
  final TextEditingController returnPolicyController = TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();

  AuctionAiController? _aiController;
  bool _listenerAttached = false;
  late List<TextEditingController> titleControllerList;
  late List<TextEditingController> descriptionControllerList;

  final List<String> productTypeList = ['Physical'];

  late String? selectedProductType = productTypeList.first;
  String? selectedCategory;
  String? selectedBrand;
  String? selectedItemCondition;
  VideoUploadType _videoUploadType = VideoUploadType.link;

  final Map<String, String> itemConditionMap = {
    "New": "NEW",
    "Like_New": "LIKE_NEW",
    "Excellent": "EXCELLENT",
    "Good": "GOOD",
    "Fair": "FAIR"
  };


  @override
  void initState() {
    super.initState();
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.language ?? [];
    _tabController = TabController(length: languages.isNotEmpty ? languages.length : 1, initialIndex: 0, vsync: this);

    titleControllerList = List.generate(languages.length, (index) => TextEditingController());
    descriptionControllerList = List.generate(languages.length, (index) => TextEditingController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      Provider.of<BrandController>(context, listen: false).getBrandList(offset: 1);
      Provider.of<CategoryController>(context, listen: false).getCategoryList(false);
      initData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAttached) {
      _aiController = Provider.of<AuctionAiController>(context, listen: false);
      _aiController!.addListener(_onAiControllerChanged);
      _listenerAttached = true;
    }
  }

  void _onAiControllerChanged() {
    if (!mounted) return;
    if (_loadDataFromImageCalled) return;

    final aiController = _aiController;
    if (aiController == null) return;

    if (aiController.requestTypeImage &&
        !aiController.setupAutoFillLoading &&
        !aiController.generalSetupLoading &&
        !aiController.shippingSetupLoading &&
        titleControllerList.isNotEmpty &&
        titleControllerList[0].text.isNotEmpty) {
      _loadDataFromImageCalled = true;
      _loadDataFromImage();
    }
  }


  @override
  void didUpdateWidget(AddAuctionProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProduct == null && widget.initialProduct != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {if (mounted) initData();});
    }
  }

  void initData() {
    final mediaController = Provider.of<AddAuctionProductMediaController>(context, listen: false);
    final p = widget.initialProduct;
    if (p == null) return;

    mediaController.reset();

    nameController.text = p.name ?? '';
    descriptionController.text = p.details ?? '';

    String? itemConditionKey;
    if (p.itemCondition != null) {
      if (itemConditionMap.containsKey(p.itemCondition)) {
        itemConditionKey = p.itemCondition;
      } else {
        final normalized = p.itemCondition!.replaceAll(' ', '_');
        if (itemConditionMap.containsKey(normalized)) {
          itemConditionKey = normalized;
        } else {
          final entry = itemConditionMap.entries.firstWhere(
            (e) => e.value == p.itemCondition,
            orElse: () => const MapEntry('', ''),
          );
          if (entry.key.isNotEmpty) itemConditionKey = entry.key;
        }
      }
    }
    shippingFeeController.text = p.shippingFee?.toString() ?? '';
    returnPolicyController.text = p.returnPolicy ?? '';

    if (p.youtubeVideoUrl != null && p.youtubeVideoUrl!.isNotEmpty) {
      videoLinkController.text = p.youtubeVideoUrl!;
    }
    if (p.customVideoUrlFullUrl?.path != null &&
        p.customVideoUrlFullUrl!.path!.isNotEmpty) {
      mediaController.setExistingVideoUrl(p.customVideoUrlFullUrl!.path!);
    }

    final languages = Provider.of<SplashController>(context, listen: false).configModel?.language ?? [];

    if (titleControllerList.isNotEmpty) titleControllerList[0].text = p.name ?? '';
    if (descriptionControllerList.isNotEmpty) descriptionControllerList[0].text = p.details ?? '';

    if (p.translations != null && p.translations!.isNotEmpty) {
      for (var t in p.translations!) {
        final idx = languages.indexWhere((lan) => lan.code == (t.locale ?? ''));
        if (idx < 0) continue;
        if (t.key == 'name' && idx < titleControllerList.length) {
          titleControllerList[idx].text = t.value ?? titleControllerList[idx].text;
        }
        if (t.key == 'description' && idx < descriptionControllerList.length) {
          descriptionControllerList[idx].text = t.value ?? descriptionControllerList[idx].text;
        }
      }
    }

    final translatedLocales = p.translations!.map((t) => t.locale).whereType<String>().toSet();
    final defaultLangIdx = languages.indexWhere((lan) => !translatedLocales.contains(lan.code));

    if (defaultLangIdx >= 0) {
      if (defaultLangIdx < titleControllerList.length) {
        titleControllerList[defaultLangIdx].text = p.name ?? '';
      }
      if (defaultLangIdx < descriptionControllerList.length) {
        descriptionControllerList[defaultLangIdx].text = p.details ?? '';
      }

    }

    if (p.thumbnailFullUrl != null) {
      mediaController.setExistingThumbnail(p.thumbnailFullUrl!.path ?? '');
    }

    if (p.seoInfo?.imageFullUrl?.path != null &&
        p.seoInfo!.imageFullUrl!.path!.isNotEmpty) {
      mediaController.setExistingSeoThumbnail(p.seoInfo!.imageFullUrl!.path!);
    }

    if (p.imagesFullUrl != null && p.imagesFullUrl!.isNotEmpty) {
      mediaController.setExistingImages(
        p.imagesFullUrl!.map((e) => e.path ?? '').where((url) => url.isNotEmpty).toList(),
      );
    }

    setState(() {
      // selectedProductType = p.productType != null
      //     ? productTypeList.firstWhere((t) => t.toLowerCase() == p.productType!.toLowerCase(), orElse: () => productTypeList.first) : null;
      selectedProductType = 'Physical';
      selectedCategory = p.category?.name;
      selectedBrand = p.brand?.name;
      if (itemConditionKey != null) {
        selectedItemCondition = itemConditionKey;
      }
      _videoUploadType = p.videoProvider == 'custom_video'
          ? VideoUploadType.file
          : VideoUploadType.link;
    });
  }

  Future<void> _loadDataFromImage() async {
    final aiController = _aiController;
    if (aiController == null) return;
    final title = titleControllerList.isNotEmpty ? titleControllerList[0].text.trim() : '';

    if (title.isEmpty) {
      return;
    }

    await aiController.generateAuctionDescription(title: title, descriptionController: descriptionControllerList[0], langCode: 'en');

    final description = descriptionControllerList[0].text.trim();
    if (!mounted || description.isEmpty) return;

    await aiController.generateGeneralSetup(title: title, description: description, langCode: 'en');
    if (mounted) _applyGeneralSetupResult();

    await aiController.generateShippingPolicySetup(title: title, description: description, langCode: 'en');
    if (mounted) {
      _applyShippingResult();
    }
  }

  void _openAiBottomSheet() {
    final splashController = Provider.of<SplashController>(context, listen: false);

    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: AuctionAiGeneratorBottomSheet(
            languageList: splashController.configModel?.language,
            tabController: _tabController,
            nameControllerList: titleControllerList,
            descriptionControllerList: descriptionControllerList,
          ),
        );
      },
    );
  }

  VideoUploadType get videoUploadType => _videoUploadType;

  @override
  void dispose() {
    _aiController?.removeListener(_onAiControllerChanged);
    _tabController?.dispose();
    nameController.dispose();
    descriptionController.dispose();
    shippingFeeController.dispose();
    returnPolicyController.dispose();
    videoLinkController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageController = Provider.of<AddAuctionProductMediaController>(context);
    final brandController = Provider.of<BrandController>(context);
    final categoryController = Provider.of<CategoryController>(context);
    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true;

    final List<String> brandNames = brandController.brandListSorted?.map((b) => b.name ?? '').where((name) => name.isNotEmpty).toList() ?? [];
    final List<String> categoryNames = categoryController.categoryList.map((c) => c.name ?? '').where((name) => name.isNotEmpty).toList();

    return Consumer<AuctionAiController>(
        builder: (context, aiController, _) {
          return Scaffold(
      floatingActionButton: aiEnabled
          ? Padding(padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          heroTag: 'add_auction_ai_fab',
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          onPressed: _openAiBottomSheet,
          child: CustomAssetImageWidget(Images.useAi, height: 56, width: 56),
        ),
      ) : null,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BasicSetupWidget(
                    tabController: _tabController,
                    nameController: titleControllerList.isNotEmpty ? titleControllerList[_tabController?.index ?? 0] : TextEditingController(),
                    descriptionController: descriptionControllerList.isNotEmpty ? descriptionControllerList[_tabController?.index ?? 0] : TextEditingController(),
                    titleControllerList: titleControllerList,
                    descriptionControllerList: descriptionControllerList,
                    thumbnailFile: imageController.thumbnailFile,
                    existingThumbnailUrl: imageController.existingThumbnailUrl,
                    onThumbnailTap: () => imageController.pickThumbnail(),
                    onThumbnailRemove: () => imageController.removeThumbnail(),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  GeneralSetupWidget(
                    productType: selectedProductType,
                    productTypeList: productTypeList,
                    onProductTypeChanged: (val) => setState(() => selectedProductType = val),
                    category: selectedCategory,
                    categoryList: categoryNames,
                    onCategoryChanged: (val) => setState(() => selectedCategory = val),
                    brand: selectedBrand,
                    brandList: brandNames,
                    onBrandChanged: (val) => setState(() => selectedBrand = val),
                    itemCondition: selectedItemCondition,

                    onItemConditionChanged: (val) {
                      setState(() => selectedItemCondition = val);
                    },

                    itemConditionMap: itemConditionMap,
                    onAiTap: _onGeneralSetupAiTap,
                    isAiGenerating: aiController.generalSetupLoading,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  AuctionShippingReturnWidget(
                    shippingFeeController: shippingFeeController,
                    returnPolicyController: returnPolicyController,
                    isAiGenerating: aiController.shippingSetupLoading,
                    onAiTap: _onShippingAiTap,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  ProductAdditionalImageWidget(
                    images: imageController.productImages,
                    existingImageUrls: imageController.existingImageUrls,
                    onAddTap: () => imageController.pickProductImage(),
                    onRemoveTap: (index) => imageController.removeProductImage(index),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  AuctionProductVideoWidget(
                    videoLinkController: videoLinkController,
                    pickedMediaFile: imageController.pickedMediaFile,
                    isPickingMedia: imageController.isPickingMedia,
                    onFileTap: () => imageController.pickSingleMedia(),
                    onFileRemove: () => imageController.removeMediaFile(),
                    onTypeChanged: (type) => setState(() => _videoUploadType = type),
                    initialType: _videoUploadType,
                    existingVideoUrl: imageController.existingVideoUrl,
                    onExistingVideoRemove: () => imageController.removeExistingVideo(),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          ),


          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey[200]!, spreadRadius: 0.5, blurRadius: 0.3)],
            ),
            child: aiController.setupAutoFillLoading
                ? const AiLoadingState()
                : NextButton(onTap: widget.onNext, isLoading: aiController.setupAutoFillLoading),
          ),
        ],
      ),
    );
  });
}
  void _onGeneralSetupAiTap() {
    final title = titleControllerList.isNotEmpty ? titleControllerList[0].text.trim() : '';
    final description = descriptionControllerList.isNotEmpty ? descriptionControllerList[0].text.trim() : '';
    if (title.isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context, snackBarType: SnackBarType.warning);
      return;
    }
    if (description.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context) ?? 'Please enter a description first', context, snackBarType: SnackBarType.warning);
      return;
    }
    Provider.of<AuctionAiController>(context, listen: false).generateGeneralSetup(title: title, description: description, langCode: 'en').then((_) => _applyGeneralSetupResult());
  }

  void _applyGeneralSetupResult() {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    final data = aiController.generalSetupModel?.auctionGeneralSetupModel?.data;
    if (data == null) return;

    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final brandController = Provider.of<BrandController>(context, listen: false);

    setState(() {
      if (data.productType != null) {
        final suggested = data.productType == 'physical' ? 'Physical' : null;
        if (suggested != null && productTypeList.contains(suggested)) selectedProductType = suggested;
      }

      if (data.categoryId != null) {
        for (final c in categoryController.categoryList) {
          if (c.id.toString() == data.categoryId.toString()) {
            selectedCategory = c.name;
            break;
          }
        }
      }

      if (data.brandId != null && brandController.brandListSorted != null) {
        for (final b in brandController.brandListSorted!) {
          if (b.id == data.brandId) {
            selectedBrand = b.name;
            break;
          }
        }
      }

      if (data.itemCondition?.isNotEmpty == true) {
        selectedItemCondition = data.itemCondition;
      }
    });
  }

  void _onShippingAiTap() {
    final title = titleControllerList.isNotEmpty ? titleControllerList[0].text.trim() : '';
    final description = descriptionControllerList.isNotEmpty ? descriptionControllerList[0].text.trim() : '';
    if (title.isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context, snackBarType: SnackBarType.warning);
      return;
    }
    if (description.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context) ?? 'Please enter a description first', context, snackBarType: SnackBarType.warning);
      return;
    }
    Provider.of<AuctionAiController>(context, listen: false).generateShippingPolicySetup(title: title, description: description, langCode: 'en').then((_) => _applyShippingResult());
  }

  void _applyShippingResult() {
    final data = Provider.of<AuctionAiController>(context, listen: false).shippingSetupModel?.data?.auctionAiShippingData;
    if (data == null) return;
    if (data.shippingFee != null) shippingFeeController.text = data.shippingFee.toString();
    if (data.returnPolicy?.isNotEmpty == true) returnPolicyController.text = data.returnPolicy!;
  }
}