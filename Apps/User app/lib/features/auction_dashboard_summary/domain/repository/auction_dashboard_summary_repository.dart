// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/datasource/remote/dio/dio_client.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/auction_dashboard_summary/domain/repository/auction_dashboard_summary_repository_interface.dart';

class AuctionDashboardSummaryRepository implements AuctionDashboardSummaryRepositoryInterface {
  final DioClient? dioClient;
  AuctionDashboardSummaryRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getAuctionDashboardSummary() async {
    return ApiResponseModel.withError('Not implemented');
  }

  @override
  Future add(value) async => ApiResponseModel.withError('Not implemented');

  @override
  Future delete(int id) async => ApiResponseModel.withError('Not implemented');

  @override
  Future get(String id) async => ApiResponseModel.withError('Not implemented');

  @override
  Future getList({int? offset = 1}) async => ApiResponseModel.withError('Not implemented');

  @override
  Future update(Map<String, dynamic> body, int id) async => ApiResponseModel.withError('Not implemented');
}
