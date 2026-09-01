// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/auction_details/domain/repositories/creator/creator_auction_details_repository_interface.dart';
import 'package:user_app/features/auction_details/domain/services/creator/creator_auction_details_service_interface.dart';

class CreatorAuctionDetailsService implements CreatorAuctionDetailsServiceInterface {
  final CreatorAuctionDetailsRepositoryInterface repoInterface;
  CreatorAuctionDetailsService({required this.repoInterface});

  @override
  Future<ApiResponseModel> getAuctionDetails({required String slug}) {
    return repoInterface.getAuctionDetails(slug: slug);
  }

  @override
  Future<ApiResponseModel> updateDeliveryStatus({required int productId, required String status}) {
    return repoInterface.updateDeliveryStatus(productId: productId, status: status);
  }

  @override
  Future<ApiResponseModel> uploadTrackingUrl({required int productId, required String url}) {
    return repoInterface.uploadTrackingUrl(productId: productId, url: url);
  }

  @override
  Future<ApiResponseModel> getBidList({required int productId, int offset = 1}) {
    return repoInterface.getBidList(productId: productId, offset: offset);
  }
}
