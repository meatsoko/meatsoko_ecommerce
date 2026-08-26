// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/repository/auction_dashboard_summary_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/services/auction_dashboard_summary_service_interface.dart';

class AuctionDashboardSummaryService implements AuctionDashboardSummaryServiceInterface {
  final AuctionDashboardSummaryRepositoryInterface repositoryInterface;
  AuctionDashboardSummaryService({required this.repositoryInterface});

  @override
  Future<ApiResponseModel> getAuctionDashboardSummary() {
    return repositoryInterface.getAuctionDashboardSummary();
  }
}
