// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/datasource/remote/dio/dio_client.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/auction_details/domain/repositories/participator/auction_participation_repository_interface.dart';

class AuctionParticipationRepository implements AuctionParticipationRepositoryInterface {
  final DioClient? dioClient;
  AuctionParticipationRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> placeAuctionBid({required int auctionProductId, required double bidAmount}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> rollbackAuctionBid({required int auctionProductId, required double bidAmount}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> withdrawAuctionBid({required int auctionProductId}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> payAuctionEntryFee({
    required int auctionProductId,
    required double feeAmount,
    required String currency,
    required String auctionStatus,
    required String paymentMethod,
    int? methodId,
    String? methodName,
    Map<String, String>? methodInformations,
    String? paymentNote,
  }) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> toggleSaveAuctionProduct({required int auctionProductId}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> getAuctionSocialShareLink({required int productId}) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> getAuctionInvoice({required int productId}) async {
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
