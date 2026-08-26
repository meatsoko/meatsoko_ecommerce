// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';

abstract class AuctionParticipationServiceInterface {
  Future<ApiResponseModel> placeAuctionBid({required int auctionProductId, required double bidAmount});

  Future<ApiResponseModel> rollbackAuctionBid({required int auctionProductId, required double bidAmount});

  Future<ApiResponseModel> withdrawAuctionBid({required int auctionProductId});

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
  });

  Future<ApiResponseModel> toggleSaveAuctionProduct({required int auctionProductId});

  Future<ApiResponseModel> getAuctionSocialShareLink({required int productId});

  Future<ApiResponseModel> getAuctionInvoice({required int productId});
}
