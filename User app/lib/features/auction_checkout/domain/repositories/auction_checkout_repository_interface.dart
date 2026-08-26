// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';

abstract class AuctionCheckoutRepositoryInterface {
  Future<ApiResponseModel> claimAuction(Map<String, dynamic> data);
  Future<ApiResponseModel> offlinePaymentList();
}
