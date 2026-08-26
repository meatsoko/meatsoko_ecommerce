// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/creator/creator_auction_details_repository_interface.dart';

class CreatorAuctionDetailsRepository implements CreatorAuctionDetailsRepositoryInterface {
  final DioClient? dioClient;
  CreatorAuctionDetailsRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getAuctionDetails({required String slug}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> updateDeliveryStatus({required int productId, required String status}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> uploadTrackingUrl({required int productId, required String url}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> getBidList({required int productId, int offset = 1}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future add(value) async => ApiResponseModel.withError('Not implemented');

  @override
  Future delete(int id) async => ApiResponseModel.withError('Not implemented');

  @override
  Future get(String id) async => ApiResponseModel.withError('Not implemented');

  @override
  Future getList({int? offset = 1}) async => ApiResponseModel.withError('Not implemented');

  @override
  Future update(Map<String, dynamic> body, int id) async => ApiResponseModel.withError('Not implemented');
}
