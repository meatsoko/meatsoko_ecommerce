// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';

abstract class ParticipationAuctionDetailsServiceInterface {
  Future<ApiResponseModel> getAuctionProductOverview({required String slug, String? auctionStatus});

  Future<ApiResponseModel> getAuctionBidList({required int productId, int offset = 1, bool isMyBid = false});
}
