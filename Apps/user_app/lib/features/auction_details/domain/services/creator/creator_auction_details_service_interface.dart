// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';

abstract class CreatorAuctionDetailsServiceInterface {
  Future<ApiResponseModel> getAuctionDetails({required String slug});

  Future<ApiResponseModel> updateDeliveryStatus({required int productId, required String status});

  Future<ApiResponseModel> uploadTrackingUrl({required int productId, required String url});

  Future<ApiResponseModel> getBidList({required int productId, int offset = 1});
}
