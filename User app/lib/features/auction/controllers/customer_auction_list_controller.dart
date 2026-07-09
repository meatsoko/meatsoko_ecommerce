import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/domain/models/customer_auction_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/domain/models/saved_auction_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/domain/service/customer_auction_list_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class CustomerAuctionListController extends ChangeNotifier {
  final CustomerAuctionListServiceInterface serviceInterface;

  CustomerAuctionListController({required this.serviceInterface});

  List<CustomerAuctionProduct> _auctionList = [];
  List<CustomerAuctionProduct> get auctionList => _auctionList;

  AuctionCounts? _counts;
  AuctionCounts? get counts => _counts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _offset = 1;
  final int _limit = 10;
  int get offset => _offset;

  int _totalSize = 0;
  int get totalSize => _totalSize;

  int _currentOffset = 1;
  int get currentOffset => _currentOffset;

  String? _selectedStatus;
  String? _selectedAuctionStatus;

  List<SavedAuctionProduct> _savedAuctionList = [];
  List<SavedAuctionProduct> get savedAuctionList => _savedAuctionList;

  bool _isSavedLoading = false;
  bool get isSavedLoading => _isSavedLoading;

  bool _hasSavedMore = true;
  bool get hasSavedMore => _hasSavedMore;

  int _savedOffset = 1;
  int get savedOffset => _savedOffset;
  final int _savedLimit = 10;

  Future<void> getCustomerAuctionList(
      BuildContext context, {
        String? status,
        String? auctionStatus,
        bool isRefresh = false,
      }) async {
    if (isRefresh) {
      _offset = 1;
      _hasMore = true;
      _auctionList = [];
      _totalSize = 0;
      _currentOffset = 1;
      _selectedStatus = status;
      _selectedAuctionStatus = auctionStatus;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    final ApiResponseModel response = await serviceInterface.getCustomerAuctionList(
      limit: _limit,
      offset: _offset,
      status: _selectedStatus,
      auctionStatus: _selectedAuctionStatus,
    );

    if (response.response != null && response.response!.statusCode == 200) {
      final CustomerAuctionListModel model = CustomerAuctionListModel.fromJson(response.response!.data);

      final List<CustomerAuctionProduct> newProducts = model.products ?? [];

      if (isRefresh) {
        _auctionList = newProducts;
        _counts = model.counts;
      } else {
        _auctionList.addAll(newProducts);
      }

      _totalSize = model.totalSize ?? 0;
      _currentOffset = model.offset ?? _offset;
      _hasMore = _auctionList.length < _totalSize;
      if (_hasMore) _offset++;
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore(BuildContext context) async {
    if (_isLoading || !_hasMore) return;
    await getCustomerAuctionList(context, status: _selectedStatus, auctionStatus: _selectedAuctionStatus);
  }

  Future<void> getCustomerSavedAuctionList(
      BuildContext context, {
        bool isRefresh = false,
      }) async {
    if (isRefresh) {
      _savedOffset = 1;
      _hasSavedMore = true;
      _savedAuctionList = [];
    }

    if (!_hasSavedMore) return;

    _isSavedLoading = true;
    notifyListeners();

    final ApiResponseModel response =
    await serviceInterface.getCustomerSavedAuctionList(
      limit: _savedLimit,
      offset: _savedOffset,
    );

    if (response.response != null && response.response!.statusCode == 200) {
      final SavedAuctionListModel model =
      SavedAuctionListModel.fromJson(response.response!.data);

      final List<SavedAuctionProduct> newProducts = model.savedProducts ?? [];

      if (isRefresh) {
        _savedAuctionList = newProducts;
      } else {
        _savedAuctionList.addAll(newProducts);
      }

      final int totalSize = model.totalSize ?? 0;
      _hasSavedMore = _savedAuctionList.length < totalSize;
      if (_hasSavedMore) _savedOffset++;
    } else {
      ApiChecker.checkApi(response);
    }

    _isSavedLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreSaved(BuildContext context) async {
    if (_isSavedLoading || !_hasSavedMore) return;
    await getCustomerSavedAuctionList(context);
  }
}