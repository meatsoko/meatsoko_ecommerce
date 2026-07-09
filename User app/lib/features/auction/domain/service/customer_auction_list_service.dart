import 'package:flutter_sixvalley_ecommerce/features/auction/domain/repository/customer_auction_list_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/domain/service/customer_auction_list_service_interface.dart';

class CustomerAuctionListService implements CustomerAuctionListServiceInterface {
  final CustomerAuctionListRepositoryInterface repositoryInterface;

  CustomerAuctionListService({required this.repositoryInterface});

  @override
  Future getCustomerAuctionList({
    required int limit,
    required int offset,
    String? status,
    String? auctionStatus,
  }) async {
    return await repositoryInterface.getCustomerAuctionList(
      limit: limit,
      offset: offset,
      status: status,
      auctionStatus: auctionStatus,
    );
  }

  @override
  Future getCustomerSavedAuctionList({
    required int limit,
    required int offset,
  }) async {
    return await repositoryInterface.getCustomerSavedAuctionList(
      limit: limit,
      offset: offset,
    );
  }
}