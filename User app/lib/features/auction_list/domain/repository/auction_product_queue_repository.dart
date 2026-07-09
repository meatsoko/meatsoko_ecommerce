import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_list/domain/repository/auction_product_queue_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class AuctionProductQueueRepository implements AuctionProductQueueRepositoryInterface {
  final DioClient? dioClient;
  AuctionProductQueueRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getAuctionProductQueueList({
    required int offset,
    required String approvalStatus,
    int limit = 10,
  }) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.customerAuctionProductRequestListUri}?limit=$limit&offset=$offset&approval_status=$approvalStatus&include_counts=true',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> deleteAuctionProduct(int id) async {
    try {
      final response = await dioClient!.delete('${AppConstants.customerAuctionProductDeleteUri}$id');
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
