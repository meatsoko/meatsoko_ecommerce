import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/domain/repository/customer_auction_list_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:provider/provider.dart';

class CustomerAuctionListRepository implements CustomerAuctionListRepositoryInterface {
  final DioClient? dioClient;

  CustomerAuctionListRepository({required this.dioClient});

  void _setRequestHeaders(String? token) {
    dioClient!.dio!.options.headers = {
      'Authorization':
      'Bearer ${token ?? Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}',
      'Content-Type': 'application/json',
    };
  }


  @override
  Future<ApiResponseModel> getCustomerAuctionList({
    required int limit,
    required int offset,
    String? status,
    String? auctionStatus,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
        'include_counts': true,
        if (auctionStatus != null) 'auction_status': auctionStatus,
      };

      final response = await dioClient!.get(
        AppConstants.customerMyBidList,
        queryParameters: queryParams,
      );

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getCustomerSavedAuctionList({
    required int limit,
    required int offset,
  }) async {
    final String token = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _setRequestHeaders(token);

    try {
      final response = await dioClient!.get(
        '${AppConstants.baseUrl}${AppConstants.auctionSaveListUri}',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override Future add(value) => throw UnimplementedError();
  @override Future delete(int id) => throw UnimplementedError();
  @override Future get(String id) => throw UnimplementedError();
  @override Future getList({int? offset = 1}) => throw UnimplementedError();
  @override Future update(Map<String, dynamic> body, int id) => throw UnimplementedError();
}