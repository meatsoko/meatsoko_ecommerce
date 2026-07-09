import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/domain/repository/auction_transaction_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/domain/service/auction_transaction_service_interface.dart';

class AuctionTransactionService implements AuctionTransactionServiceInterface {
  final AuctionTransactionRepositoryInterface repositoryInterface;
  AuctionTransactionService({required this.repositoryInterface});

  @override
  Future getAuctionTransactionList({
    int? searchAuctionId,
    int limit = 10,
    int offset = 1,
    String? filterBy,
    String? filterDurationType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repositoryInterface.getAuctionTransactionList(
      searchAuctionId: searchAuctionId,
      limit: limit,
      offset: offset,
      filterBy: filterBy,
      filterDurationType: filterDurationType,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future getSalesReport({required String dateType, String? startDate, String? endDate}) {
    return repositoryInterface.getSalesReport(dateType: dateType, startDate: startDate, endDate: endDate);
  }
}
