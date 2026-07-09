import 'package:flutter_sixvalley_ecommerce/features/auction_list/domain/repository/auction_product_queue_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_list/domain/services/auction_product_queue_service_interface.dart';

class AuctionProductQueueService implements AuctionProductQueueServiceInterface {
  final AuctionProductQueueRepositoryInterface auctionProductRepoInterface;
  AuctionProductQueueService({required this.auctionProductRepoInterface});

  @override
  Future getAuctionProductQueueList({
    required int offset,
    required String approvalStatus,
    int limit = 10,
  }) async {
    return await auctionProductRepoInterface.getAuctionProductQueueList(
      offset: offset,
      approvalStatus: approvalStatus,
      limit: limit,
    );
  }

  @override
  Future deleteAuctionProduct(int id) async {
    return await auctionProductRepoInterface.deleteAuctionProduct(id);
  }
}
