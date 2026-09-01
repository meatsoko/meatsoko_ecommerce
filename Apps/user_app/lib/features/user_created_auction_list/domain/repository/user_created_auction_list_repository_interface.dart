// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class UserCreatedAuctionListRepositoryInterface extends RepositoryInterface {
  Future<ApiResponseModel> getMyAuctionList({required String status, required int offset, int limit = 10});
}
