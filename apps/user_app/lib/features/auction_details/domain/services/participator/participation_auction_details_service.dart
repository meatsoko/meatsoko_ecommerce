// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/auction_details/domain/repositories/participator/participation_auction_details_repository_interface.dart';
import 'package:user_app/features/auction_details/domain/services/participator/participation_auction_details_service_interface.dart';

class ParticipationAuctionDetailsService implements ParticipationAuctionDetailsServiceInterface {
  final ParticipationAuctionDetailsRepositoryInterface participationAuctionDetailsRepositoryInterface;
  ParticipationAuctionDetailsService({required this.participationAuctionDetailsRepositoryInterface});

  @override
  Future<ApiResponseModel> getAuctionProductOverview({required String slug, String? auctionStatus}) {
    return participationAuctionDetailsRepositoryInterface.getAuctionProductOverview(slug: slug, auctionStatus: auctionStatus);
  }

  @override
  Future<ApiResponseModel> getAuctionBidList({required int productId, int offset = 1, bool isMyBid = false}) {
    return participationAuctionDetailsRepositoryInterface.getAuctionBidList(productId: productId, offset: offset, isMyBid: isMyBid);
  }
}
