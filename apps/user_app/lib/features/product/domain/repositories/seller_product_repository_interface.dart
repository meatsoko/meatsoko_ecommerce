import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class SellerProductRepositoryInterface implements RepositoryInterface{

  Future<dynamic> getSellerProductList(String sellerId, String offset, String productId, {String search = '', String? categoryIds, String? brandIds, String? authorIds, String? publishingIds, String? productType});

  Future<dynamic> getSellerWiseBestSellingProductList(String slug, String offset);

  Future<dynamic> getSellerWiseFeaturedProductList(String slug, String offset);

  Future<dynamic> getSellerWiseRecommendedProductList(String slug, String offset);

  Future<ApiResponseModel<T>> getShopAgainFromRecentStore<T>({required DataSourceEnum source});
}
