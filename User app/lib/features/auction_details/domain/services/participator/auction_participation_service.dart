// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/participator/auction_participation_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/participator/auction_participation_service_interface.dart';

class AuctionParticipationService implements AuctionParticipationServiceInterface {
  final AuctionParticipationRepositoryInterface auctionRepositoryInterface;
  AuctionParticipationService({required this.auctionRepositoryInterface});

  @override
  Future<ApiResponseModel> placeAuctionBid({required int auctionProductId, required double bidAmount}) {
    return auctionRepositoryInterface.placeAuctionBid(auctionProductId: auctionProductId, bidAmount: bidAmount);
  }

  @override
  Future<ApiResponseModel> rollbackAuctionBid({required int auctionProductId, required double bidAmount}) {
    return auctionRepositoryInterface.rollbackAuctionBid(auctionProductId: auctionProductId, bidAmount: bidAmount);
  }

  @override
  Future<ApiResponseModel> withdrawAuctionBid({required int auctionProductId}) {
    return auctionRepositoryInterface.withdrawAuctionBid(auctionProductId: auctionProductId);
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
  }) {
    return auctionRepositoryInterface.payAuctionEntryFee(
      auctionProductId: auctionProductId,
      feeAmount: feeAmount,
      currency: currency,
      auctionStatus: auctionStatus,
      paymentMethod: paymentMethod,
      methodId: methodId,
      methodName: methodName,
      methodInformations: methodInformations,
      paymentNote: paymentNote,
    );
  }

  @override
  Future<ApiResponseModel> toggleSaveAuctionProduct({required int auctionProductId}) {
    return auctionRepositoryInterface.toggleSaveAuctionProduct(auctionProductId: auctionProductId);
  }

  @override
  Future<ApiResponseModel> getAuctionSocialShareLink({required int productId}) {
    return auctionRepositoryInterface.getAuctionSocialShareLink(productId: productId);
  }

  @override
  Future<ApiResponseModel> getAuctionInvoice({required int productId}) {
    return auctionRepositoryInterface.getAuctionInvoice(productId: productId);
  }
}
