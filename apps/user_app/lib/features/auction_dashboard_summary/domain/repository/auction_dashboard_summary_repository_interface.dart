// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class AuctionDashboardSummaryRepositoryInterface extends RepositoryInterface {
  Future<ApiResponseModel> getAuctionDashboardSummary();
}
