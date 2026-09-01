// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/datasource/remote/dio/dio_client.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/auction_transaction/domain/repository/auction_transaction_repository_interface.dart';

class AuctionTransactionRepository implements AuctionTransactionRepositoryInterface {
  final DioClient? dioClient;
  AuctionTransactionRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getAuctionTransactionList({
    int? searchAuctionId,
    int limit = 10,
    int offset = 1,
    String? filterBy,
    String? filterDurationType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future<ApiResponseModel> getSalesReport({required String dateType, String? startDate, String? endDate}) async {
    return ApiResponseModel.withError('Not implemented');
  }
}
