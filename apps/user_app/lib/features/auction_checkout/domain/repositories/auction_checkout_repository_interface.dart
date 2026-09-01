// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';

abstract class AuctionCheckoutRepositoryInterface {
  Future<ApiResponseModel> claimAuction(Map<String, dynamic> data);
  Future<ApiResponseModel> offlinePaymentList();
}
