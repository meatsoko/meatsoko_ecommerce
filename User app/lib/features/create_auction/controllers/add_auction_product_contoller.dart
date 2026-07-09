import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_media_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/domain/models/add_auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/auction_product_video_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/models/tax_vat_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/domain/services/add_auction_product_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddAuctionProductController extends ChangeNotifier {
  final AddAuctionProductServiceInterface addAuctionProductServiceInterface;

  AddAuctionProductController({required this.addAuctionProductServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? seoMetaTitle;
  String? seoMetaDescription;
  String? seoMetaIndex;
  String? seoMetaNoFollow;       // 'nofollow' or '0'
  String? seoMetaNoImageIndex;   // '1' or '0'
  String? seoMetaNoArchive;      // '1' or '0'
  String? seoMetaNoSnippet;      // '1' or '0'
  String? seoMetaMaxSnippet;     // '1' or '0'
  String? seoMetaMaxSnippetValue;
  String? seoMetaMaxVideoPreview;      // '1' or '0'
  String? seoMetaMaxVideoPreviewValue;
  String? seoMetaMaxImagePreview;      // '1' or '0'
  String? seoMetaMaxImagePreviewValue; // 'none' | 'standard' | 'large'

  void updateSeoFields({
    String? metaTitle,
    String? metaDescription,
    String? metaIndex,
    String? metaNoFollow,
    String? metaNoImageIndex,
    String? metaNoArchive,
    String? metaNoSnippet,
    String? metaMaxSnippet,
    String? metaMaxSnippetValue,
    String? metaMaxVideoPreview,
    String? metaMaxVideoPreviewValue,
    String? metaMaxImagePreview,
    String? metaMaxImagePreviewValue,
  }) {
    if (metaTitle != null) seoMetaTitle = metaTitle;
    if (metaDescription != null) seoMetaDescription = metaDescription;
    if (metaIndex != null) seoMetaIndex = metaIndex;
    if (metaNoFollow != null) seoMetaNoFollow = metaNoFollow;
    if (metaNoImageIndex != null) seoMetaNoImageIndex = metaNoImageIndex;
    if (metaNoArchive != null) seoMetaNoArchive = metaNoArchive;
    if (metaNoSnippet != null) seoMetaNoSnippet = metaNoSnippet;
    if (metaMaxSnippet != null) seoMetaMaxSnippet = metaMaxSnippet;
    if (metaMaxSnippetValue != null) seoMetaMaxSnippetValue = metaMaxSnippetValue;
    if (metaMaxVideoPreview != null) seoMetaMaxVideoPreview = metaMaxVideoPreview;
    if (metaMaxVideoPreviewValue != null) seoMetaMaxVideoPreviewValue = metaMaxVideoPreviewValue;
    if (metaMaxImagePreview != null) seoMetaMaxImagePreview = metaMaxImagePreview;
    if (metaMaxImagePreviewValue != null) seoMetaMaxImagePreviewValue = metaMaxImagePreviewValue;

  }

  void resetSeoFields() {
    seoMetaTitle = null;
    seoMetaDescription = null;
    seoMetaIndex = null;
    seoMetaNoFollow = null;
    seoMetaNoImageIndex = null;
    seoMetaNoArchive = null;
    seoMetaNoSnippet = null;
    seoMetaMaxSnippet = null;
    seoMetaMaxSnippetValue = null;
    seoMetaMaxVideoPreview = null;
    seoMetaMaxVideoPreviewValue = null;
    seoMetaMaxImagePreview = null;
    seoMetaMaxImagePreviewValue = null;
  }

  bool validateGeneralInfo(
      BuildContext context, {
        required TextEditingController nameController,
        required TextEditingController descriptionController,
        XFile? thumbnailFile,
        String? existingThumbnailUrl,
        required String? selectedProductType,
        required String? selectedCategory,
        required String? selectedItemCondition,
        required TextEditingController shippingFeeController,
        required TextEditingController returnPolicyController,
        required List<dynamic> additionalImages,
        required TextEditingController videoLinkController,
        required VideoUploadType videoUploadType,
      }) {
    if (nameController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_product_name', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (selectedProductType == null || selectedProductType.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_select_product_type', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (selectedCategory == null || selectedCategory.isEmpty) {
      showCustomSnackBarWidget(getTranslated('select_a_category', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (selectedItemCondition == null || selectedItemCondition.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_select_item_condition', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (shippingFeeController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_shipping_cost', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (returnPolicyController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_return_policy', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (additionalImages.isEmpty) {
      showCustomSnackBarWidget(getTranslated('upload_product_image', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (thumbnailFile == null && (existingThumbnailUrl == null || existingThumbnailUrl.isEmpty)) {
      showCustomSnackBarWidget(getTranslated('upload_thumbnail_image', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (videoUploadType == VideoUploadType.link) {
      final videoLink = videoLinkController.text.trim();
      if (videoLink.isNotEmpty && !videoLink.contains('youtube.com/embed/')) {
        showCustomSnackBarWidget(getTranslated('provide_embedded_link', context), context, snackBarType: SnackBarType.warning);
        return false;
      }
    }
    return true;
  }

  bool validateAuctionInfo(
      BuildContext context, {
        required TextEditingController startPriceController,
        required TextEditingController minimumIncrementController,
        required TextEditingController maximumDecrementController,
        required List<VatTaxModel>? selectedVatTaxRate,
        required DateTime? startTime,
        required DateTime? endTime,
      }) {
    if (startPriceController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_start_price', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    final double? startPrice = double.tryParse(startPriceController.text.trim());
    if (startPrice == null || startPrice <= 0) {
      showCustomSnackBarWidget(getTranslated('please_enter_valid_start_price', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (minimumIncrementController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_minimum_increment', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    final double? minIncrement = double.tryParse(minimumIncrementController.text.trim());
    if (minIncrement == null || minIncrement <= 0) {
      showCustomSnackBarWidget(getTranslated('please_enter_valid_minimum_increment', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (maximumDecrementController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_maximum_decrement', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    final double? maxDecrement = double.tryParse(maximumDecrementController.text.trim());
    if (maxDecrement == null || maxDecrement <= 0) {
      showCustomSnackBarWidget(getTranslated('please_enter_valid_maximum_decrement', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    final systemTaxType = Provider.of<SplashController>(context, listen: false).configModel?.systemTaxType;

    if (systemTaxType == 'product_wise') {
      if (selectedVatTaxRate == null || selectedVatTaxRate.isEmpty) {
        showCustomSnackBarWidget(getTranslated('please_add_your_product_tax', context), context, snackBarType: SnackBarType.warning);
        return false;
      }
    }
    if (startTime == null) {
      showCustomSnackBarWidget(getTranslated('please_select_start_time', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (endTime == null) {
      showCustomSnackBarWidget(getTranslated('please_select_end_time', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (!endTime.isAfter(startTime)) {
      showCustomSnackBarWidget(getTranslated('end_time_must_be_after_start_time', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (startTime.isBefore(DateTime.now())) {
      showCustomSnackBarWidget(getTranslated('start_time_must_be_in_future', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    return true;
  }


  Future<ApiResponseModel?> addAuctionProduct(
      BuildContext context, {
        required List<TextEditingController> nameController,
        required List<TextEditingController> descriptionController,
        required String? selectedCategory,
        required String? selectedBrand,
        required String? selectedProductType,
        required TextEditingController shippingFeeController,
        required TextEditingController returnPolicyController,
        required TextEditingController videoLinkController,
        required VideoUploadType videoUploadType,
        required TextEditingController entryFeeController,
        required String? itemCondition,
        required TextEditingController startPriceController,
        required TextEditingController minimumIncrementController,
        required TextEditingController maximumDecrementController,
        required List<VatTaxModel>? selectedVatTax,
        required DateTime? startTime,
        required DateTime? endTime,
        List<String> tags = const [],
        required TextEditingController metaTitleController,
        required TextEditingController metaDescriptionController,
        XFile? metaImageFile,
      }) async {
    _isLoading = true;
    notifyListeners();

    final mediaController = Provider.of<AddAuctionProductMediaController>(context, listen: false);
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final brandController = Provider.of<BrandController>(context, listen: false);
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.language ?? [];
    final languageList = languages.map((l) => l.code ?? 'en').toList();

    int categoryId = 0;
    if (selectedCategory != null) {
      final matched = categoryController.categoryList.where((c) => c.name == selectedCategory).firstOrNull;
      if (matched != null) categoryId = matched.id ?? 0;
    }

    int? brandId;
    if (selectedBrand != null && brandController.brandList.isNotEmpty) {
      final matched = brandController.brandList.where((b) => b.name == selectedBrand).firstOrNull;
      if (matched != null) brandId = matched.id;
    }

    final titleList = nameController.map((c) => c.text.trim()).toList();
    final descriptionList = descriptionController.map((c) => c.text.trim()).toList();
    final String? tagsCsv = tags.isNotEmpty ? tags.join(',') : null;

    final String? resolvedVideoType = videoUploadType == VideoUploadType.link
        ? (videoLinkController.text.trim().isNotEmpty ? 'youtube_link' : null)
        : (mediaController.pickedMediaFile != null ? 'custom_video' : null);

    final addAuctionModel = AddAuctionProductModel(
      titleList: titleList,
      descriptionList: descriptionList,
      languageList: languageList,
      videoUrl: resolvedVideoType == 'youtube_link' ? videoLinkController.text.trim() : null,
      videoType: resolvedVideoType,
    );

    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final startTimeStr = formatter.format(startTime!);
    final endTimeStr = formatter.format(endTime!);
    final duration = endTime.difference(startTime).inDays;

    List<int>? taxIds;
    if (selectedVatTax != null && selectedVatTax.isNotEmpty) {
      taxIds = [];
      for (var tax in selectedVatTax) {
        if (tax.id != null) {
          taxIds.add(tax.id!);
        }
      }
    }

    final thumbnail = mediaController.thumbnailFile;
    final images = mediaController.productImages;

    if (thumbnail == null) {
      showCustomSnackBarWidget(getTranslated('upload_thumbnail_image', context), context, snackBarType: SnackBarType.warning);
      _isLoading = false;
      notifyListeners();
      return null;
    }
    if (images.isEmpty) {
      showCustomSnackBarWidget(getTranslated('upload_product_image', context), context, snackBarType: SnackBarType.warning);
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final videoType = addAuctionModel.videoType;
    XFile? customerVideo;
    if (videoType == 'custom_video' && mediaController.pickedMediaFile != null) {
      customerVideo = mediaController.pickedMediaFile!.file;
    }

    final String? currencyCode = Provider.of<SplashController>(context, listen: false).myCurrency?.code;

    ApiResponseModel? response;
    try {
      response = await addAuctionProductServiceInterface.addAuctionProduct(
        addAuctionProduct: addAuctionModel,
        categoryId: categoryId,
        brandId: brandId,
        productType: selectedProductType?.toLowerCase() ?? 'physical',
        itemCondition: itemCondition ?? 'new',
        entryFee: double.tryParse(entryFeeController.text.trim()) ?? 0,
        startingPrice: double.tryParse(startPriceController.text.trim()) ?? 0,
        minimumIncrementAmount: double.tryParse(minimumIncrementController.text.trim()) ?? 0,
        maximumDecrementAmount: double.tryParse(maximumDecrementController.text.trim()) ?? 0,
        startTime: startTimeStr,
        endTime: endTimeStr,
        duration: duration > 0 ? duration : 1,
        status: 1,
        shippingFee: double.tryParse(shippingFeeController.text.trim()) ?? 0,
        returnPolicy: returnPolicyController.text.trim(),
        thumbnail: thumbnail,
        images: images,
        videoType: videoType,
        youtubeVideo: videoLinkController.text.trim().isNotEmpty ? videoLinkController.text.trim() : null,
        customerVideo: customerVideo,
        taxIds: taxIds,
        tags: tagsCsv,
        metaTitle: seoMetaTitle?.isNotEmpty == true ? seoMetaTitle : null,
        metaDescription: seoMetaDescription?.isNotEmpty == true ? seoMetaDescription : null,
        metaIndex: seoMetaIndex,
        metaNoFollow: seoMetaNoFollow,
        metaNoImageIndex: seoMetaNoImageIndex,
        metaNoArchive: seoMetaNoArchive,
        metaNoSnippet: seoMetaNoSnippet,
        metaMaxSnippet: seoMetaMaxSnippet,
        metaMaxSnippetValue: seoMetaMaxSnippetValue,
        metaMaxVideoPreview: seoMetaMaxVideoPreview,
        metaMaxVideoPreviewValue: seoMetaMaxVideoPreviewValue,
        metaMaxImagePreview: seoMetaMaxImagePreview,
        metaMaxImagePreviewValue: seoMetaMaxImagePreviewValue,
        metaImage: metaImageFile,
        currentCurrencyCode: currencyCode,
      );

      if (response?.response?.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        mediaController.reset();
        resetSeoFields();
        showCustomSnackBarWidget(getTranslated('auction_product_added_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
      } else {
        _isLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('product_add_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    return response;
  }

  Future<ApiResponseModel?> updateAuctionProduct(
      BuildContext context, {
        required int productId,
        required List<TextEditingController> nameController,
        required List<TextEditingController> descriptionController,
        required String? selectedCategory,
        required String? selectedBrand,
        required String? selectedProductType,
        required TextEditingController shippingFeeController,
        required TextEditingController returnPolicyController,
        required TextEditingController videoLinkController,
        required VideoUploadType videoUploadType,
        required TextEditingController entryFeeController,
        required String? itemCondition,
        required TextEditingController startPriceController,
        required TextEditingController minimumIncrementController,
        required TextEditingController maximumDecrementController,
        required List<VatTaxModel>? selectedVatTax,
        required DateTime? startTime,
        required DateTime? endTime,
        List<String> tags = const [],
        required TextEditingController metaTitleController,
        required TextEditingController metaDescriptionController,
        XFile? metaImageFile,
      }) async {
    _isLoading = true;
    notifyListeners();

    final mediaController = Provider.of<AddAuctionProductMediaController>(context, listen: false);
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final brandController = Provider.of<BrandController>(context, listen: false);
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.language ?? [];
    final languageList = languages.map((l) => l.code ?? 'en').toList();

    int categoryId = 0;
    if (selectedCategory != null) {
      final matched = categoryController.categoryList.where((c) => c.name == selectedCategory).firstOrNull;
      if (matched != null) categoryId = matched.id ?? 0;
    }

    int? brandId;
    if (selectedBrand != null && brandController.brandList.isNotEmpty) {
      final matched = brandController.brandList.where((b) => b.name == selectedBrand).firstOrNull;
      if (matched != null) brandId = matched.id;
    }

    final titleList = nameController.map((c) => c.text.trim()).toList();
    final descriptionList = descriptionController.map((c) => c.text.trim()).toList();
    final String? tagsCsv = tags.isNotEmpty ? tags.join(',') : null;

    final String? resolvedVideoType = videoUploadType == VideoUploadType.link
        ? (videoLinkController.text.trim().isNotEmpty ? 'youtube_link' : null)
        : (mediaController.pickedMediaFile != null ? 'custom_video' : null);

    final updateAuctionModel = AddAuctionProductModel(
      titleList: titleList,
      descriptionList: descriptionList,
      languageList: languageList,
      videoUrl: resolvedVideoType == 'youtube_link' ? videoLinkController.text.trim() : null,
      videoType: resolvedVideoType,
    );

    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final startTimeStr = formatter.format(startTime!);
    final endTimeStr = formatter.format(endTime!);
    final duration = endTime.difference(startTime).inDays;

    List<int>? taxIds;
    if (selectedVatTax != null && selectedVatTax.isNotEmpty) {
      taxIds = [];
      for (var tax in selectedVatTax) {
        if (tax.id != null) {
          taxIds.add(tax.id!);
        }
      }
    }

    final thumbnail = mediaController.thumbnailFile;
    final images = mediaController.productImages.isNotEmpty ? mediaController.productImages : null;

    final videoType = updateAuctionModel.videoType;
    XFile? customerVideo;
    if (videoType == 'custom_video' && mediaController.pickedMediaFile != null) {
      customerVideo = mediaController.pickedMediaFile!.file;
    }

    final String? currencyCode = Provider.of<SplashController>(context, listen: false).myCurrency?.code;

    ApiResponseModel? response;
    try {
      response = await addAuctionProductServiceInterface.updateAuctionProduct(
        productId: productId,
        addAuctionProduct: updateAuctionModel,
        categoryId: categoryId,
        brandId: brandId,
        productType: selectedProductType?.toLowerCase() ?? 'physical',
        itemCondition: itemCondition ?? 'new',
        entryFee: double.tryParse(entryFeeController.text.trim()) ?? 0,
        startingPrice: double.tryParse(startPriceController.text.trim()) ?? 0,
        minimumIncrementAmount: double.tryParse(minimumIncrementController.text.trim()) ?? 0,
        maximumDecrementAmount: double.tryParse(maximumDecrementController.text.trim()) ?? 0,
        startTime: startTimeStr,
        endTime: endTimeStr,
        duration: duration > 0 ? duration : 1,
        status: 1,
        shippingFee: double.tryParse(shippingFeeController.text.trim()) ?? 0,
        returnPolicy: returnPolicyController.text.trim(),
        thumbnail: thumbnail,
        images: images,
        videoType: videoType,
        youtubeVideo: videoLinkController.text.trim().isNotEmpty ? videoLinkController.text.trim() : null,
        customerVideo: customerVideo,
        taxIds: taxIds,
        tags: tagsCsv,
        metaTitle: seoMetaTitle?.isNotEmpty == true ? seoMetaTitle : null,
        metaDescription: seoMetaDescription?.isNotEmpty == true ? seoMetaDescription : null,
        metaIndex: seoMetaIndex,
        metaNoFollow: seoMetaNoFollow,
        metaNoImageIndex: seoMetaNoImageIndex,
        metaNoArchive: seoMetaNoArchive,
        metaNoSnippet: seoMetaNoSnippet,
        metaMaxSnippet: seoMetaMaxSnippet,
        metaMaxSnippetValue: seoMetaMaxSnippetValue,
        metaMaxVideoPreview: seoMetaMaxVideoPreview,
        metaMaxVideoPreviewValue: seoMetaMaxVideoPreviewValue,
        metaMaxImagePreview: seoMetaMaxImagePreview,
        metaMaxImagePreviewValue: seoMetaMaxImagePreviewValue,
        metaImage: metaImageFile,
        currentCurrencyCode: currencyCode,
      );

      if (response?.response?.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('auction_product_updated_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
      } else {
        _isLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('product_update_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    return response;
  }

  Future<ApiResponseModel?> relaunchAuction(
      BuildContext context, {
        required int productId,
        required List<TextEditingController> nameController,
        required List<TextEditingController> descriptionController,
        required String? selectedCategory,
        required String? selectedBrand,
        required String? selectedProductType,
        required TextEditingController shippingFeeController,
        required TextEditingController returnPolicyController,
        required TextEditingController videoLinkController,
        required VideoUploadType videoUploadType,
        required TextEditingController entryFeeController,
        required String? itemCondition,
        required TextEditingController startPriceController,
        required TextEditingController minimumIncrementController,
        required TextEditingController maximumDecrementController,
        required List<VatTaxModel>? selectedVatTax,
        required DateTime? startTime,
        required DateTime? endTime,
        List<String> tags = const [],
        required TextEditingController metaTitleController,
        required TextEditingController metaDescriptionController,
        XFile? metaImageFile,
      }) async {
    _isLoading = true;
    notifyListeners();

    final mediaController = Provider.of<AddAuctionProductMediaController>(context, listen: false);
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final brandController = Provider.of<BrandController>(context, listen: false);
    final languages = Provider.of<SplashController>(context, listen: false).configModel?.language ?? [];
    final languageList = languages.map((l) => l.code ?? 'en').toList();

    int categoryId = 0;
    if (selectedCategory != null) {
      final matched = categoryController.categoryList.where((c) => c.name == selectedCategory).firstOrNull;
      if (matched != null) categoryId = matched.id ?? 0;
    }

    int? brandId;
    if (selectedBrand != null && brandController.brandList.isNotEmpty) {
      final matched = brandController.brandList.where((b) => b.name == selectedBrand).firstOrNull;
      if (matched != null) brandId = matched.id;
    }

    final titleList = nameController.map((c) => c.text.trim()).toList();
    final descriptionList = descriptionController.map((c) => c.text.trim()).toList();
    final String? tagsCsv = tags.isNotEmpty ? tags.join(',') : null;

    final String? resolvedVideoType = videoUploadType == VideoUploadType.link
        ? (videoLinkController.text.trim().isNotEmpty ? 'youtube_link' : null)
        : (mediaController.pickedMediaFile != null ? 'custom_video' : null);

    final relaunchModel = AddAuctionProductModel(
      titleList: titleList,
      descriptionList: descriptionList,
      languageList: languageList,
      videoUrl: resolvedVideoType == 'youtube_link' ? videoLinkController.text.trim() : null,
      videoType: resolvedVideoType,
    );

    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final startTimeStr = formatter.format(startTime!);
    final endTimeStr = formatter.format(endTime!);
    final duration = endTime.difference(startTime).inDays;

    List<int>? taxIds;
    if (selectedVatTax != null && selectedVatTax.isNotEmpty) {
      taxIds = [];
      for (var tax in selectedVatTax) {
        if (tax.id != null) taxIds.add(tax.id!);
      }
    }

    final thumbnail = mediaController.thumbnailFile;
    final images = mediaController.productImages.isNotEmpty ? mediaController.productImages : null;

    final videoType = relaunchModel.videoType;
    XFile? customerVideo;
    if (videoType == 'custom_video' && mediaController.pickedMediaFile != null) {
      customerVideo = mediaController.pickedMediaFile!.file;
    }

    final String? currencyCode = Provider.of<SplashController>(context, listen: false).myCurrency?.code;

    ApiResponseModel? response;
    try {
      response = await addAuctionProductServiceInterface.relaunchAuction(
        auctionId: productId,
        addAuctionProduct: relaunchModel,
        categoryId: categoryId,
        brandId: brandId,
        productType: selectedProductType?.toLowerCase() ?? 'physical',
        itemCondition: itemCondition ?? 'new',
        entryFee: double.tryParse(entryFeeController.text.trim()) ?? 0,
        startingPrice: double.tryParse(startPriceController.text.trim()) ?? 0,
        minimumIncrementAmount: double.tryParse(minimumIncrementController.text.trim()) ?? 0,
        maximumDecrementAmount: double.tryParse(maximumDecrementController.text.trim()) ?? 0,
        startTime: startTimeStr,
        endTime: endTimeStr,
        duration: duration > 0 ? duration : 1,
        status: 1,
        shippingFee: double.tryParse(shippingFeeController.text.trim()) ?? 0,
        returnPolicy: returnPolicyController.text.trim(),
        thumbnail: thumbnail,
        images: images,
        videoType: videoType,
        youtubeVideo: videoLinkController.text.trim().isNotEmpty ? videoLinkController.text.trim() : null,
        customerVideo: customerVideo,
        taxIds: taxIds,
        tags: tagsCsv,
        metaTitle: seoMetaTitle?.isNotEmpty == true ? seoMetaTitle : null,
        metaDescription: seoMetaDescription?.isNotEmpty == true ? seoMetaDescription : null,
        metaIndex: seoMetaIndex,
        metaNoFollow: seoMetaNoFollow,
        metaNoImageIndex: seoMetaNoImageIndex,
        metaNoArchive: seoMetaNoArchive,
        metaNoSnippet: seoMetaNoSnippet,
        metaMaxSnippet: seoMetaMaxSnippet,
        metaMaxSnippetValue: seoMetaMaxSnippetValue,
        metaMaxVideoPreview: seoMetaMaxVideoPreview,
        metaMaxVideoPreviewValue: seoMetaMaxVideoPreviewValue,
        metaMaxImagePreview: seoMetaMaxImagePreview,
        metaMaxImagePreviewValue: seoMetaMaxImagePreviewValue,
        metaImage: metaImageFile,
        currentCurrencyCode: currencyCode,
      );

      if (response?.response?.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('auction_relaunched_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
      } else {
        _isLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('something_went_wrong', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    return response;
  }

  Future<bool> deleteAuctionProduct(BuildContext context, {required int productId}) async {
    _isLoading = true;
    notifyListeners();

    bool isSuccess = false;
    try {
      final ApiResponseModel response = await addAuctionProductServiceInterface.deleteAuctionProduct(productId: productId);

      if (response.response?.statusCode == 200) {
        isSuccess = true;
        _isLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('auction_product_deleted_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
      } else if (response.response?.statusCode == 404) {
        _isLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('auction_product_not_found', Get.context!), Get.context!, snackBarType: SnackBarType.error);
      } else {
        _isLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('product_delete_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    return isSuccess;
  }

  Future<bool> cancelAuctionProduct(BuildContext context, {required int productId}) async {
    _isLoading = true;
    notifyListeners();

    bool isSuccess = false;
    try {
      final ApiResponseModel response = await addAuctionProductServiceInterface.cancelAuctionProduct(productId: productId);

      if (response.response?.statusCode == 200) {
        isSuccess = true;
        _isLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('auction_cancelled_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
      } else if (response.response?.statusCode == 404) {
        _isLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('auction_product_not_found', Get.context!), Get.context!, snackBarType: SnackBarType.error);
      } else {
        _isLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('auction_cancel_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    return isSuccess;
  }
}