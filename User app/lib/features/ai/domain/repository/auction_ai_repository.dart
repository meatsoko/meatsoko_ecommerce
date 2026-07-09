import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/domain/repository/auction_ai_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';


class AuctionAiRepository implements AuctionAiRepositoryInterface {
  final DioClient? dioClient;

  AuctionAiRepository({required this.dioClient});

  @override
  Future<ApiResponseModel?> generateAuctionTitle({
    required String title,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionTitleAutoFill,
        data: {
          'name': title,
          'langCode': langCode,
        },
      );
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateAuctionDescription({
    required String title,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionDescriptionAutoFill,
        data: {
          'name': title,
          'langCode': langCode,
        },
      );
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateGeneralData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionGeneralSetupAutoFill,
        data: {
          'name': title,
          'description': description,
          'langCode': langCode,
        },
      );
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateShippingData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionShippingPolicyAutoFill,
        data: {
          'name': title,
          'description': description,
          'langCode': langCode,
        },
      );
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateMetaSeoData({
    required String title,
    required String description,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionSeoSectionAutoFill,
        data: {
          'name': title,
          'description': description,
        },
      );
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateAuctionInfoData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionInfoAutoFill,
        data: {
          'name': title,
          'description': description,
          'langCode': langCode,
        },
      );
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateLimitCheck() async {
    try {
      final response = await dioClient?.get(AppConstants.auctionGenerateLimitCheck);
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateFromImage({required XFile image}) async {
    try {
      MultipartFile multiPartFile = MultipartFile.fromBytes(
        await image.readAsBytes(),
        filename: image.name,
      );
      final response = await dioClient?.postMultipart(
        AppConstants.auctionAnalyzeImageAutoFill,
        data: {},
        files: [MultipartWithKey(key: 'image', multipartFile: multiPartFile)],
      );
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateSetupAutoFill({
    required String name,
    required String langCode,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionSetupAutoFill,
        data: {'name': name, 'langCode': langCode},
      );
      return ApiResponseModel.withSuccess(response!);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel?> generateTitleSuggestions({
    required List<String> keywords,
  }) async {
    try {
      final response = await dioClient?.post(
        AppConstants.auctionGenerateTitleSuggestions,
        data: {'keywords': keywords},
      );
      return ApiResponseModel.withSuccess(response!);
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
