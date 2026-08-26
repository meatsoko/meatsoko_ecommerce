// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/models/auction_dashboard_summary_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/services/auction_dashboard_summary_service_interface.dart';

class AuctionDashboardSummaryController extends ChangeNotifier {
  final AuctionDashboardSummaryServiceInterface serviceInterface;
  AuctionDashboardSummaryController({required this.serviceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuctionDashboardSummaryModel? _summaryModel;
  AuctionDashboardSummaryModel? get summaryModel => _summaryModel;

  Future<void> getAuctionDashboardSummary(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final ApiResponseModel response = await serviceInterface.getAuctionDashboardSummary();

    _isLoading = false;
    notifyListeners();

    if (response.isSuccess) {
      // Stub service never actually succeeds; kept for shape completeness.
    }
  }
}
