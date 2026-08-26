// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/repository/user_created_auction_list_repository_interface.dart';

class UserCreatedAuctionListRepository implements UserCreatedAuctionListRepositoryInterface {
  final DioClient? dioClient;
  UserCreatedAuctionListRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getMyAuctionList({required String status, required int offset, int limit = 10}) async {
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
