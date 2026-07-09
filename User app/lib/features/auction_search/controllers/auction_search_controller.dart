import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/domain/models/auction_filter_param_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/domain/models/auction_popular_tag_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/domain/services/auction_search_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/domain/models/suggestion_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class AuctionSearchController extends ChangeNotifier {
  final AuctionSearchServiceInterface? auctionSearchServiceInterface;
  AuctionSearchController({required this.auctionSearchServiceInterface});

  String _searchText = '';
  String get searchText => _searchText;

  AuctionProductListModel? _auctionListModel;
  AuctionProductListModel? get auctionListModel => _auctionListModel;

  bool _isAuctionListLoading = false;
  bool get isAuctionListLoading => _isAuctionListLoading;

  AuctionFilterParamModel _filterParams = const AuctionFilterParamModel();
  AuctionFilterParamModel get filterParams => _filterParams;

  bool get isFilterApplied => _filterParams.activeFilterCount > 0;

  List<String> _savedSearchNames = [];
  List<String> get savedSearchNames => _savedSearchNames;

  AuctionPopularTagModel? _popularTagModel;
  AuctionPopularTagModel? get popularTagModel => _popularTagModel;

  bool _isPopularTagsLoading = false;
  bool get isPopularTagsLoading => _isPopularTagsLoading;

  void loadSavedSearchNames() {
    _savedSearchNames = auctionSearchServiceInterface!.getSavedAuctionSearchNames();
    notifyListeners();
  }

  Future<void> saveSearchName(String searchText) async {
    if (searchText.trim().isEmpty) return;
    await auctionSearchServiceInterface!.saveAuctionSearchName(searchText.trim());
    loadSavedSearchNames();
  }

  Future<void> removeSearchName(int index) async {
    _savedSearchNames.removeAt(index);
    await auctionSearchServiceInterface!.clearSavedAuctionSearchNames();
    for (final name in _savedSearchNames) {
      await auctionSearchServiceInterface!.saveAuctionSearchName(name);
    }
    notifyListeners();
  }

  Future<void> clearSavedSearchNames() async {
    await auctionSearchServiceInterface!.clearSavedAuctionSearchNames();
    _savedSearchNames = [];
    notifyListeners();
  }

  void updateSearchText(String value, {bool isUpdate = true}) {
    _searchText = value;
    if (isUpdate) notifyListeners();
  }

  void applyFilter(AuctionFilterParamModel filter) {
    _filterParams = filter;
    notifyListeners();
  }

  void clearFilter() {
    _filterParams = const AuctionFilterParamModel();
    notifyListeners();
  }

  Future<void> getAuctionList({
    String auctionStatus = '',
    String search = '',
    required int offset,
    bool reload = false,
    AuctionFilterParamModel? filter,
  }) async {
    if (reload || offset == 1) {
      _auctionListModel = null;
      _isAuctionListLoading = true;
      notifyListeners();
    }

    final AuctionFilterParamModel effectiveFilter = filter ?? _filterParams;

    final Map<String, dynamic> extraParams = effectiveFilter.toQueryParams();
    if (auctionStatus.isNotEmpty) extraParams.remove('auction_status');
    if (search.isNotEmpty) extraParams.remove('search');

    final ApiResponseModel apiResponse =
    await auctionSearchServiceInterface!.getAuctionSearchList(
      offset: offset,
      auctionStatus: auctionStatus.isNotEmpty ? auctionStatus : (effectiveFilter.auctionStatus ?? ''),
      search: search,
      extraParams: extraParams,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        _auctionListModel =
            AuctionProductListModel.fromJson(apiResponse.response!.data);
      } else {
        final newData =
        AuctionProductListModel.fromJson(apiResponse.response!.data);
        _auctionListModel?.products?.addAll(newData.products ?? []);
        _auctionListModel?.offset = newData.offset;
        _auctionListModel?.totalSize = newData.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isAuctionListLoading = false;
    notifyListeners();
  }

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  SuggestionModel? _suggestionModel;
  SuggestionModel? get suggestionModel => _suggestionModel;

  List<String> nameList = [];
  List<int> idList = [];

  Future<List<String>> getSuggestionAuctionProductName(String name) async {
    final ApiResponseModel apiResponse =
    await auctionSearchServiceInterface!.getAuctionSuggestionProductName(name);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      nameList = [];
      idList = [];
      _suggestionModel = SuggestionModel.fromJson(apiResponse.response?.data);
      for (int i = 0; i < _suggestionModel!.products!.length; i++) {
        nameList.add(_suggestionModel!.products![i].name!);
        idList.add(_suggestionModel!.products![i].id!);
      }
    }
    return nameList;
  }

  void cleanAuctionSearch({bool notify = false}) {
    _auctionListModel = null;
    _searchText = '';
    _filterParams = const AuctionFilterParamModel();
    _isAuctionListLoading = false;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> getAuctionPopularTags({int limit = 10}) async {
    _isPopularTagsLoading = true;
    notifyListeners();

    final ApiResponseModel apiResponse = await auctionSearchServiceInterface!.getAuctionPopularTags(limit: limit);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _popularTagModel = AuctionPopularTagModel.fromJson(apiResponse.response!.data);
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isPopularTagsLoading = false;
    notifyListeners();
  }

  void setSearchText(String value, {bool notify = true}) {
    _searchText = value;
    searchController.text = value;
    searchController.selection = TextSelection.fromPosition(TextPosition(offset: value.length));
    if (notify) notifyListeners();
  }
}