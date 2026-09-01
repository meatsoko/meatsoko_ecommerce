// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class CustomerAuctionListRepositoryInterface extends RepositoryInterface {
  Future<ApiResponseModel> getCustomerAuctionList({
    required int limit,
    required int offset,
    String? status,
    String? auctionStatus,
  });

  Future<ApiResponseModel> getCustomerSavedAuctionList({
    required int limit,
    required int offset,
  });
}
