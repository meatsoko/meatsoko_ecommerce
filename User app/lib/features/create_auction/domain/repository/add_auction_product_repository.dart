import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/domain/models/add_auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/domain/repository/add_auction_product_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';


class AddAuctionProductRepository implements AddAuctionProductRepositoryInterface {
  final DioClient? dioClient;
  AddAuctionProductRepository({required this.dioClient});

  void _setRequestHeaders(String? token) {
    final String? countryCode = dioClient!.countryCode;
    final String langValue = (countryCode == null || countryCode == 'US') ? 'en' : countryCode.toLowerCase();

    dioClient!.dio!.options.headers = {
      'Authorization': 'Bearer ${token ?? Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}',
      AppConstants.langKey: langValue,
    };
  }

  @override
  Future<ApiResponseModel> addAuctionProduct({
    required AddAuctionProductModel addAuctionProduct,
    required int categoryId,
    int? brandId,
    required String productType,
    required String itemCondition,
    required double entryFee,
    required double startingPrice,
    required double minimumIncrementAmount,
    required double maximumDecrementAmount,
    required String startTime,
    required String endTime,
    int? duration,
    required int status,
    required double shippingFee,
    String? returnPolicy,
    required XFile thumbnail,
    required List<XFile> images,
    String? videoType,
    String? youtubeVideo,
    XFile? customerVideo,
    List<int>? taxIds,
    String? tags,
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
    XFile? metaImage,
    String? currentCurrencyCode,
  }) async {

    String? token = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _setRequestHeaders(token);

    try {
      // Build the request data map
      Map<String, dynamic> fields = {};
      
      // Prepare multipart files
      List<MultipartWithKey> multipartFiles = [];

      // Basic auction product fields
      fields['name'] = jsonEncode(addAuctionProduct.titleList);
      fields['lang'] = jsonEncode(addAuctionProduct.languageList);
      fields['description'] = jsonEncode(addAuctionProduct.descriptionList);
      fields['category_id'] = categoryId;
      if (brandId != null) {
        fields['brand_id'] = brandId;
      }
      fields['product_type'] = productType;
      fields['item_condition'] = itemCondition;
      fields['entry_fee'] = entryFee;
      fields['starting_price'] = startingPrice;
      fields['minimum_increment_amount'] = minimumIncrementAmount;
      fields['maximum_decrement_amount'] = maximumDecrementAmount;
      fields['start_time'] = startTime;
      fields['end_time'] = endTime;
      if (duration != null) {
        fields['duration'] = duration;
      }
      fields['status'] = status;
      fields['shipping_fee'] = shippingFee;
      if (currentCurrencyCode != null) fields['current_currency_code'] = currentCurrencyCode;
      if (returnPolicy != null && returnPolicy.isNotEmpty) {
        fields['return_policy'] = returnPolicy;
      }

      // Video fields
      if (videoType != null && videoType.isNotEmpty) {
        fields['video_provider'] = videoType;
      }
      if (youtubeVideo != null && youtubeVideo.isNotEmpty) {
        fields['youtube_video_url'] = youtubeVideo;
      }

      // Tax
      if (taxIds != null && taxIds.isNotEmpty) {
        fields['tax_ids'] = jsonEncode(taxIds);
      }

      // Search tags (comma-separated string)
      if (tags != null && tags.isNotEmpty) {
        fields['tags'] = tags;
      }

      // Meta / SEO fields
      if (metaTitle != null) fields['meta_title'] = metaTitle;
      if (metaDescription != null) fields['meta_description'] = metaDescription;
      if (metaIndex != null) fields['meta_index'] = metaIndex;
      if (metaNoFollow != null) fields['meta_no_follow'] = metaNoFollow;
      if (metaNoImageIndex != null) fields['meta_no_image_index'] = metaNoImageIndex;
      if (metaNoArchive != null) fields['meta_no_archive'] = metaNoArchive;
      if (metaNoSnippet != null) fields['meta_no_snippet'] = metaNoSnippet;
      if (metaMaxSnippet != null) fields['meta_max_snippet'] = metaMaxSnippet;
      if (metaMaxSnippetValue != null) fields['meta_max_snippet_value'] = metaMaxSnippetValue;
      if (metaMaxVideoPreview != null) fields['meta_max_video_preview'] = metaMaxVideoPreview;
      if (metaMaxVideoPreviewValue != null) fields['meta_max_video_preview_value'] = metaMaxVideoPreviewValue;
      if (metaMaxImagePreview != null) fields['meta_max_image_preview'] = metaMaxImagePreview;
      if (metaMaxImagePreviewValue != null) fields['meta_max_image_preview_value'] = metaMaxImagePreviewValue;
      if (metaImage != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'meta_image',
          multipartFile: MultipartFile.fromBytes(
            await metaImage.readAsBytes(),
            filename: basename(metaImage.path),
          ),
        ));
      }

      // Thumbnail
      multipartFiles.add(MultipartWithKey(
        key: 'thumbnail',
        multipartFile: MultipartFile.fromBytes(
          await thumbnail.readAsBytes(),
          filename: basename(thumbnail.path),
        ),
      ));

      // Product images
      for (int i = 0; i < images.length; i++) {
        multipartFiles.add(MultipartWithKey(
          key: 'images[]',
          multipartFile: MultipartFile.fromBytes(
            await images[i].readAsBytes(),
            filename: basename(images[i].path),
          ),
        ));
      }

      // Customer video (if applicable)
      if (videoType == 'custom_video' && customerVideo != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'custom_video_url',
          multipartFile: MultipartFile.fromBytes(
            await customerVideo.readAsBytes(),
            filename: basename(customerVideo.path),
          ),
        ));
      }

      Response response = await dioClient!.postMultipart(
        AppConstants.createAuctionProductsUri,
        data: fields,
        files: multipartFiles,
      );

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> updateAuctionProduct({
    required int productId,
    required AddAuctionProductModel addAuctionProduct,
    required int categoryId,
    int? brandId,
    required String productType,
    required String itemCondition,
    required double entryFee,
    required double startingPrice,
    required double minimumIncrementAmount,
    required double maximumDecrementAmount,
    required String startTime,
    required String endTime,
    int? duration,
    required int status,
    required double shippingFee,
    String? returnPolicy,
    XFile? thumbnail,
    List<XFile>? images,
    String? videoType,
    String? youtubeVideo,
    XFile? customerVideo,
    List<int>? taxIds,
    String? tags,
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
    XFile? metaImage,
    String? currentCurrencyCode,
  }) async {
    String? token = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _setRequestHeaders(token);

    try {
      Map<String, dynamic> fields = {};
      List<MultipartWithKey> multipartFiles = [];

      fields['name'] = jsonEncode(addAuctionProduct.titleList);
      fields['lang'] = jsonEncode(addAuctionProduct.languageList);
      fields['description'] = jsonEncode(addAuctionProduct.descriptionList);
      fields['category_id'] = categoryId;
      if (brandId != null) fields['brand_id'] = brandId;
      fields['product_type'] = productType;
      fields['item_condition'] = itemCondition;
      fields['entry_fee'] = entryFee;
      fields['starting_price'] = startingPrice;
      fields['minimum_increment_amount'] = minimumIncrementAmount;
      fields['maximum_decrement_amount'] = maximumDecrementAmount;
      fields['start_time'] = startTime;
      fields['end_time'] = endTime;
      if (duration != null) fields['duration'] = duration;
      fields['status'] = status;
      fields['shipping_fee'] = shippingFee;
      if (currentCurrencyCode != null) fields['current_currency_code'] = currentCurrencyCode;
      if (returnPolicy != null && returnPolicy.isNotEmpty) {
        fields['return_policy'] = returnPolicy;
      }

      if (videoType != null && videoType.isNotEmpty) {
        fields['video_provider'] = videoType;
      }
      if (youtubeVideo != null && youtubeVideo.isNotEmpty) {
        fields['youtube_video_url'] = youtubeVideo;
      }

      if (taxIds != null && taxIds.isNotEmpty) {
        fields['tax_ids'] = jsonEncode(taxIds);
      }

      // Search tags (comma-separated string)
      if (tags != null && tags.isNotEmpty) {
        fields['tags'] = tags;
      }

      if (metaTitle != null) fields['meta_title'] = metaTitle;
      if (metaDescription != null) fields['meta_description'] = metaDescription;
      if (metaIndex != null) fields['meta_index'] = metaIndex;
      if (metaNoFollow != null) fields['meta_no_follow'] = metaNoFollow;
      if (metaNoImageIndex != null) fields['meta_no_image_index'] = metaNoImageIndex;
      if (metaNoArchive != null) fields['meta_no_archive'] = metaNoArchive;
      if (metaNoSnippet != null) fields['meta_no_snippet'] = metaNoSnippet;
      if (metaMaxSnippet != null) fields['meta_max_snippet'] = metaMaxSnippet;
      if (metaMaxSnippetValue != null) fields['meta_max_snippet_value'] = metaMaxSnippetValue;
      if (metaMaxVideoPreview != null) fields['meta_max_video_preview'] = metaMaxVideoPreview;
      if (metaMaxVideoPreviewValue != null) fields['meta_max_video_preview_value'] = metaMaxVideoPreviewValue;
      if (metaMaxImagePreview != null) fields['meta_max_image_preview'] = metaMaxImagePreview;
      if (metaMaxImagePreviewValue != null) fields['meta_max_image_preview_value'] = metaMaxImagePreviewValue;

      // Optional files for update
      if (thumbnail != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'thumbnail',
          multipartFile: MultipartFile.fromBytes(
            await thumbnail.readAsBytes(),
            filename: basename(thumbnail.path),
          ),
        ));
      }

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          multipartFiles.add(MultipartWithKey(
            key: 'images[]',
            multipartFile: MultipartFile.fromBytes(
              await images[i].readAsBytes(),
              filename: basename(images[i].path),
            ),
          ));
        }
      }

      if (videoType == 'custom_video' && customerVideo != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'custom_video_url',
          multipartFile: MultipartFile.fromBytes(
            await customerVideo.readAsBytes(),
            filename: basename(customerVideo.path),
          ),
        ));
      }

      if (metaImage != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'meta_image',
          multipartFile: MultipartFile.fromBytes(
            await metaImage.readAsBytes(),
            filename: basename(metaImage.path),
          ),
        ));
      }

      // PUT via postMultipart with _method override
      fields['_method'] = 'PUT';

      Response response = await dioClient!.postMultipart(
        '${AppConstants.updateAuctionProductsUri}/$productId',
        data: fields,
        files: multipartFiles,
      );

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> deleteAuctionProduct({required int productId}) async {
    String? token = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _setRequestHeaders(token);

    try {
      Response response = await dioClient!.delete(
        '${AppConstants.customerAuctionProductDeleteUri}$productId',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> cancelAuctionProduct({required int productId}) async {
    String? token = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _setRequestHeaders(token);

    try {
      final Map<String, dynamic> fields = {'is_canceled': true};
      Response response = await dioClient!.post(
        '${AppConstants.customerAuctionProductCancelUri}$productId',
        data: fields,
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponseModel> relaunchAuction({
    required int auctionId,
    required AddAuctionProductModel addAuctionProduct,
    required int categoryId,
    int? brandId,
    required String productType,
    required String itemCondition,
    required double entryFee,
    required double startingPrice,
    required double minimumIncrementAmount,
    required double maximumDecrementAmount,
    required String startTime,
    required String endTime,
    int? duration,
    required int status,
    required double shippingFee,
    String? returnPolicy,
    XFile? thumbnail,
    List<XFile>? images,
    String? videoType,
    String? youtubeVideo,
    XFile? customerVideo,
    List<int>? taxIds,
    String? tags,
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
    XFile? metaImage,
    String? currentCurrencyCode,
  }) async {
    String? token = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _setRequestHeaders(token);

    try {
      Map<String, dynamic> fields = {};
      List<MultipartWithKey> multipartFiles = [];

      fields['name'] = jsonEncode(addAuctionProduct.titleList);
      fields['lang'] = jsonEncode(addAuctionProduct.languageList);
      fields['description'] = jsonEncode(addAuctionProduct.descriptionList);
      fields['category_id'] = categoryId;
      if (brandId != null) fields['brand_id'] = brandId;
      fields['product_type'] = productType;
      fields['item_condition'] = itemCondition;
      fields['entry_fee'] = entryFee;
      fields['starting_price'] = startingPrice;
      fields['minimum_increment_amount'] = minimumIncrementAmount;
      fields['maximum_decrement_amount'] = maximumDecrementAmount;
      fields['start_time'] = startTime;
      fields['end_time'] = endTime;
      if (duration != null) fields['duration'] = duration;
      fields['status'] = status;
      fields['shipping_fee'] = shippingFee;
      if (currentCurrencyCode != null) fields['current_currency_code'] = currentCurrencyCode;
      if (returnPolicy != null && returnPolicy.isNotEmpty) {
        fields['return_policy'] = returnPolicy;
      }

      if (videoType != null && videoType.isNotEmpty) {
        fields['video_provider'] = videoType;
      }
      if (youtubeVideo != null && youtubeVideo.isNotEmpty) {
        fields['youtube_video_url'] = youtubeVideo;
      }

      if (taxIds != null && taxIds.isNotEmpty) {
        fields['tax_ids'] = jsonEncode(taxIds);
      }

      if (tags != null && tags.isNotEmpty) {
        fields['tags'] = tags;
      }

      if (metaTitle != null) fields['meta_title'] = metaTitle;
      if (metaDescription != null) fields['meta_description'] = metaDescription;
      if (metaIndex != null) fields['meta_index'] = metaIndex;
      if (metaNoFollow != null) fields['meta_no_follow'] = metaNoFollow;
      if (metaNoImageIndex != null) fields['meta_no_image_index'] = metaNoImageIndex;
      if (metaNoArchive != null) fields['meta_no_archive'] = metaNoArchive;
      if (metaNoSnippet != null) fields['meta_no_snippet'] = metaNoSnippet;
      if (metaMaxSnippet != null) fields['meta_max_snippet'] = metaMaxSnippet;
      if (metaMaxSnippetValue != null) fields['meta_max_snippet_value'] = metaMaxSnippetValue;
      if (metaMaxVideoPreview != null) fields['meta_max_video_preview'] = metaMaxVideoPreview;
      if (metaMaxVideoPreviewValue != null) fields['meta_max_video_preview_value'] = metaMaxVideoPreviewValue;
      if (metaMaxImagePreview != null) fields['meta_max_image_preview'] = metaMaxImagePreview;
      if (metaMaxImagePreviewValue != null) fields['meta_max_image_preview_value'] = metaMaxImagePreviewValue;

      if (thumbnail != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'thumbnail',
          multipartFile: MultipartFile.fromBytes(
            await thumbnail.readAsBytes(),
            filename: basename(thumbnail.path),
          ),
        ));
      }

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          multipartFiles.add(MultipartWithKey(
            key: 'images[]',
            multipartFile: MultipartFile.fromBytes(
              await images[i].readAsBytes(),
              filename: basename(images[i].path),
            ),
          ));
        }
      }

      if (videoType == 'custom_video' && customerVideo != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'custom_video_url',
          multipartFile: MultipartFile.fromBytes(
            await customerVideo.readAsBytes(),
            filename: basename(customerVideo.path),
          ),
        ));
      }

      if (metaImage != null) {
        multipartFiles.add(MultipartWithKey(
          key: 'meta_image',
          multipartFile: MultipartFile.fromBytes(
            await metaImage.readAsBytes(),
            filename: basename(metaImage.path),
          ),
        ));
      }

      Response response = await dioClient!.postMultipart(
        '${AppConstants.auctionRelaunchUri}$auctionId',
        data: fields,
        files: multipartFiles,
      );

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }
}
