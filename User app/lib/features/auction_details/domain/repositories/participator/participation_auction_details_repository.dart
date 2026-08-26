// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/participator/participation_auction_details_repository_interface.dart';

class ParticipationAuctionDetailsRepository implements ParticipationAuctionDetailsRepositoryInterface {
  final DioClient? dioClient;
  ParticipationAuctionDetailsRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getAuctionProductOverview({required String slug, String? auctionStatus}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> getAuctionBidList({required int productId, int offset = 1, bool isMyBid = false}) async {
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
