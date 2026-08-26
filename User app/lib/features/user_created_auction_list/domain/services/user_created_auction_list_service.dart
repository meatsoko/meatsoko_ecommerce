// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/repository/user_created_auction_list_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/services/user_created_auction_list_service_interface.dart';

class UserCreatedAuctionListService implements UserCreatedAuctionListServiceInterface {
  final UserCreatedAuctionListRepositoryInterface userCreatedAuctionListRepositoryInterface;
  UserCreatedAuctionListService({required this.userCreatedAuctionListRepositoryInterface});

  @override
  Future<ApiResponseModel> getMyAuctionList({required String status, required int offset, int limit = 10}) {
    return userCreatedAuctionListRepositoryInterface.getMyAuctionList(status: status, offset: offset, limit: limit);
  }
}
