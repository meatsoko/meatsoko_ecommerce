// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class AuctionProductQueueRepositoryInterface extends RepositoryInterface {
  Future<ApiResponseModel> getAuctionProductQueueList({
    required int offset,
    required String approvalStatus,
    int limit = 10,
  });

  Future<ApiResponseModel> deleteAuctionProduct(int id);
}
