import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/domain/models/auction_sales_report_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/domain/models/auction_transaction_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/domain/service/auction_transaction_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

enum AuctionReportDateType { allTime, today, week, month, year, custom }

extension AuctionReportDateTypeExt on AuctionReportDateType {
  String get value {
    switch (this) {
      case AuctionReportDateType.allTime: return '';
      case AuctionReportDateType.today:   return 'today';
      case AuctionReportDateType.week:    return 'this_week';
      case AuctionReportDateType.month:   return 'this_month';
      case AuctionReportDateType.year:    return 'this_year';
      case AuctionReportDateType.custom:  return 'custom_date';
    }
  }
}

class AuctionTransactionController extends ChangeNotifier {
  final AuctionTransactionServiceInterface serviceInterface;
  AuctionTransactionController({required this.serviceInterface});

  AuctionTransactionListModel? _listModel;
  List<AuctionTransactionModel> _transactions = [];
  bool _isLoading = false;

  List<AuctionTransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  int? get totalSize => _listModel?.totalSize;
  int? get offset => _listModel?.offset;

  bool _isReportLoading = false;
  bool get isReportLoading => _isReportLoading;

  AuctionSalesReportModel? _salesReport;
  AuctionSalesReportModel? get salesReport => _salesReport;

  AuctionReportDateType _selectedDateType = AuctionReportDateType.allTime;
  AuctionReportDateType get selectedDateType => _selectedDateType;

  // Filter state
  String? _selectedFilterBy;
  String? get selectedFilterBy => _selectedFilterBy;

  String _selectedDurationType = 'all';
  String get selectedDurationType => _selectedDurationType;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  // Applied filter state (what's actually in use)
  String? _appliedFilterBy;
  String _appliedDurationType = 'all';
  DateTime? _appliedStartDate;
  DateTime? _appliedEndDate;

  int get activeFilterCount {
    int count = 0;
    if (_appliedFilterBy != null && _appliedFilterBy != 'all') count++;
    if (_appliedDurationType != 'all') count++;
    return count;
  }

  void initFilterData() {
    _selectedFilterBy = _appliedFilterBy;
    _selectedDurationType = _appliedDurationType;
    _startDate = _appliedStartDate;
    _endDate = _appliedEndDate;
    notifyListeners();
  }

  void setSelectedFilterBy({String? type}) {
    _selectedFilterBy = type;
    notifyListeners();
  }

  void setSelectedDurationType(String type) {
    _selectedDurationType = type;
    if (type != 'custom') {
      _startDate = null;
      _endDate = null;
    }
    notifyListeners();
  }

  void setSelectedDate({required DateTime? startDate, required DateTime? endDate}) {
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }

  Future<void> getAuctionTransactionList(
    BuildContext context, {
    bool isRefresh = false,
    int offset = 1,
    int? searchAuctionId,
    String? filterBy,
    String? filterDurationType,
    DateTime? startDate,
    DateTime? endDate,
    bool applyFilter = false,
  }) async {
    if (applyFilter) {
      _appliedFilterBy = filterBy;
      _appliedDurationType = filterDurationType ?? 'all';
      _appliedStartDate = startDate;
      _appliedEndDate = endDate;
    }
    if (isRefresh) _transactions = [];
    _isLoading = true;
    notifyListeners();

    final ApiResponseModel response = await serviceInterface.getAuctionTransactionList(
      searchAuctionId: searchAuctionId,
      limit: 10,
      offset: offset,
      filterBy: filterBy ?? _appliedFilterBy,
      filterDurationType: filterDurationType ?? _appliedDurationType,
      startDate: startDate ?? _appliedStartDate,
      endDate: endDate ?? _appliedEndDate,
    );

    if (response.response != null && response.response!.statusCode == 200) {
      _listModel = AuctionTransactionListModel.fromJson(response.response!.data);
      final List<AuctionTransactionModel> newItems = _listModel?.transactions ?? [];
      if (isRefresh) {
        _transactions = newItems;
      } else {
        _transactions.addAll(newItems);
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getSalesReport({AuctionReportDateType? dateType, String? startDate, String? endDate}) async {
    if (dateType != null) _selectedDateType = dateType;
    _isReportLoading = true;
    notifyListeners();

    final ApiResponseModel response = await serviceInterface.getSalesReport(
      dateType: _selectedDateType.value,
      startDate: startDate,
      endDate: endDate,
    );

    if (response.response?.statusCode == 200) {
      _salesReport = AuctionSalesReportModel.fromJson(response.response!.data);
    }

    _isReportLoading = false;
    notifyListeners();
  }
}
