import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/domain/repositories/auction_checkout_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/domain/services/auction_checkout_service_interface.dart';

class AuctionCheckoutService implements AuctionCheckoutServiceInterface {
  final AuctionCheckoutRepositoryInterface auctionCheckoutRepositoryInterface;
  AuctionCheckoutService({required this.auctionCheckoutRepositoryInterface});

  @override
  Future<dynamic> claimAuction(Map<String, dynamic> data) async {
    return await auctionCheckoutRepositoryInterface.claimAuction(data);
  }

  @override
  Future<dynamic> offlinePaymentList() async {
    return await auctionCheckoutRepositoryInterface.offlinePaymentList();
  }
}
