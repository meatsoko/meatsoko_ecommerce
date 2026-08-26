// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class UserCreatedAuctionListRepositoryInterface extends RepositoryInterface {
  Future<ApiResponseModel> getMyAuctionList({required String status, required int offset, int limit = 10});
}
