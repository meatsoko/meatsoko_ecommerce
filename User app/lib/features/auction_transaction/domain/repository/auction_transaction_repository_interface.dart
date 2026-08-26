// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';

abstract class AuctionTransactionRepositoryInterface {
  Future<ApiResponseModel> getAuctionTransactionList({
    int? searchAuctionId,
    int limit = 10,
    int offset = 1,
    String? filterBy,
    String? filterDurationType,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<ApiResponseModel> getSalesReport({required String dateType, String? startDate, String? endDate});
}
