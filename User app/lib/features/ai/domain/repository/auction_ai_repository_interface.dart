import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';
import 'package:image_picker/image_picker.dart';


abstract class AuctionAiRepositoryInterface implements RepositoryInterface {
  Future<ApiResponseModel?> generateAuctionTitle({
    required String title,
    required String langCode,
  });

  Future<ApiResponseModel?> generateAuctionDescription({
    required String title,
    required String langCode,
  });

  Future<ApiResponseModel?> generateGeneralData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<ApiResponseModel?> generateShippingData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<ApiResponseModel?> generateMetaSeoData({
    required String title,
    required String description,
  });

  Future<ApiResponseModel?> generateAuctionInfoData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<ApiResponseModel?> generateLimitCheck();

  Future<ApiResponseModel?> generateFromImage({required XFile image});

  Future<ApiResponseModel?> generateSetupAutoFill({
    required String name,
    required String langCode,
  });

  Future<ApiResponseModel?> generateTitleSuggestions({
    required List<String> keywords,
  });
}
