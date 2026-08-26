// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/participator/participation_auction_details_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/participator/participation_auction_details_service_interface.dart';

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
