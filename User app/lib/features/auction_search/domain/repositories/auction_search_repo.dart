import 'package:flutter/foundation.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/domain/repositories/auction_search_repo_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionSearchRepository implements AuctionSearchRepoInterface {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  AuctionSearchRepository({required this.dioClient, required this.sharedPreferences});
  
  @override
  Future<ApiResponseModel> getAuctionSearchList({
    required int offset,
    String auctionStatus = '',
    String search = '',
    int limit = 10,
    Map<String, dynamic> extraParams = const {},
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
        if (search.isNotEmpty) 'search': search,
        if (auctionStatus.isNotEmpty) 'auction_status': auctionStatus,
        ...extraParams,
      };

      debugPrint('===AuctionSearch Request Fields==> $queryParams');

      final response = await dioClient!.post(AppConstants.auctionProductListUri, data: queryParams);

      debugPrint('===AuctionSearch Response==> $response');

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<void> saveAuctionSearchName(String searchText) async {
    try {
      List<String> list = sharedPreferences!.getStringList(AppConstants.auctionSearchProductName) ?? [];
      if (!list.contains(searchText)) {
        list.add(searchText);
      }
      await sharedPreferences!.setStringList(AppConstants.auctionSearchProductName, list);
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<String> getSavedAuctionSearchNames() {
    return sharedPreferences!.getStringList(AppConstants.auctionSearchProductName) ?? [];
  }

  @override
  Future<bool> clearSavedAuctionSearchNames() async {
    return sharedPreferences!.setStringList(AppConstants.auctionSearchProductName, []);
  }

  @override
  Future<ApiResponseModel> getAuctionSuggestionProductName(String search) async {
    try {
      final response = await dioClient!.get('${AppConstants.getAuctionSuggestionProductName}?search=$search&limit=10&offset=1');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getAuctionPopularTags({int limit = 10}) async {
    try {
      final response = await dioClient!.get('${AppConstants.auctionPopularTags}?limit=$limit');
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
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }
}
