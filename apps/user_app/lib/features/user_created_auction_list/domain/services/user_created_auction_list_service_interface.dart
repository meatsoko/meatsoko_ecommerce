// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';

abstract class UserCreatedAuctionListServiceInterface {
  Future<ApiResponseModel> getMyAuctionList({required String status, required int offset, int limit = 10});
}
