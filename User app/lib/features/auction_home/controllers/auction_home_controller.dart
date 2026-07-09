import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/recently_viewed_auction_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/services/auction_home_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/helper/data_sync_helper.dart';

class AuctionHomeController extends ChangeNotifier {
  final AuctionHomeServiceInterface? auctionHomeServiceInterface;
  AuctionHomeController({required this.auctionHomeServiceInterface});

  AuctionProductListModel? _allAuctionModel;
  AuctionProductListModel? _endingSoonModel;
  AuctionProductListModel? _trendingModel;
  AuctionProductListModel? _liveModel;
  AuctionProductListModel? _upcomingModel;

  RecentlyViewedAuctionModel? _recentlyViewedModel;

  AuctionProductListModel? get allAuctionModel => _allAuctionModel;
  AuctionProductListModel? get endingSoonModel => _endingSoonModel;
  AuctionProductListModel? get trendingModel => _trendingModel;
  AuctionProductListModel? get liveModel => _liveModel;
  AuctionProductListModel? get upcomingModel => _upcomingModel;

  RecentlyViewedAuctionModel? get recentlyViewedModel => _recentlyViewedModel;

  bool get isLoaded => _allAuctionModel != null && _endingSoonModel != null && _trendingModel != null && _liveModel != null && _upcomingModel != null;

  Future<void> fetchWithCache({bool isLoggedIn = false}) async {
    if (isLoaded) return;
    await getAllAuctionHomeSections();
    await getRecentlyViewedAuctionList(isLoggedIn: isLoggedIn);
  }

  Future<void> getAuctionHomeSection(AuctionEnum section, {int? offset, int? categoryId, int? ownerId}) async {
    if ((offset ?? 1) == 1) {
      _setSectionModel(section, null);
      notifyListeners();
    }
    await DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () => auctionHomeServiceInterface!.getAuctionHomeSection(
        section: section,
        source: DataSourceEnum.local,
        offset: offset ?? 1,
        categoryId: categoryId,
        ownerId: ownerId,
      ),
      fetchFromClient: () => auctionHomeServiceInterface!.getAuctionHomeSection(
        section: section,
        source: DataSourceEnum.client,
        offset: offset ?? 1,
        categoryId: categoryId,
        ownerId: ownerId,
      ),
      onResponse: (data, source) {
        try {
          final newModel = AuctionProductListModel.fromJson(data);

          if ((offset ?? 1) == 1) {
            _setSectionModel(section, newModel);
          } else {
            final currentModel = _getSectionModel(section);
            if (currentModel != null) {
              currentModel.products!.addAll(newModel.products ?? []);
              currentModel.offset = newModel.offset;
              currentModel.totalSize = newModel.totalSize;
            }
          }
        } catch (_) {
          if ((offset ?? 1) == 1) {
            _setSectionModel(section, AuctionProductListModel(products: []));
          }
        }
        notifyListeners();
      },
    );
  }

  Future<void> getAllAuctionHomeSections() async {
    for (final section in AuctionEnum.values) {
      await getAuctionHomeSection(section);
    }
  }

  void _setSectionModel(AuctionEnum section, AuctionProductListModel? model) {
    switch (section) {
      case AuctionEnum.all:
        _allAuctionModel = model;
      case AuctionEnum.endingSoon:
        _endingSoonModel = model;
      case AuctionEnum.trending:
        _trendingModel = model;
      case AuctionEnum.live:
        _liveModel = model;
      case AuctionEnum.upcoming:
        _upcomingModel = model;
    }
  }

  AuctionProductListModel? _getSectionModel(AuctionEnum section) {
    switch (section) {
      case AuctionEnum.all:        return _allAuctionModel;
      case AuctionEnum.endingSoon: return _endingSoonModel;
      case AuctionEnum.trending:   return _trendingModel;
      case AuctionEnum.live:       return _liveModel;
      case AuctionEnum.upcoming:   return _upcomingModel;
    }
  }

  Future<void> getRecentlyViewedAuctionList({int offset = 1, bool isUpdate = true, bool isLoggedIn = false}) async {
    if (!isLoggedIn) {
      _recentlyViewedModel = RecentlyViewedAuctionModel(recentViews: []);
      if (isUpdate) notifyListeners();
      return;
    }

    if (offset == 1) {
      _recentlyViewedModel = null;
      if (isUpdate) notifyListeners();
    }

    final ApiResponseModel apiResponse =
    await auctionHomeServiceInterface!.getRecentlyViewedAuctionList(offset: offset);

    if (apiResponse.response?.statusCode == 200) {
      try {
        final newModel = RecentlyViewedAuctionModel.fromJson(apiResponse.response?.data);
        if (offset == 1) {
          _recentlyViewedModel = newModel;
        } else {
          _recentlyViewedModel!.recentViews!.addAll(newModel.recentViews ?? []);
          _recentlyViewedModel!.offset = newModel.offset;
          _recentlyViewedModel!.totalSize = newModel.totalSize;
        }
      } catch (_) {
        if (offset == 1) {
          _recentlyViewedModel = RecentlyViewedAuctionModel(recentViews: []);
        }
      }
    } else {
      ApiChecker.checkApi(apiResponse);
      if (offset == 1) {
        _recentlyViewedModel = RecentlyViewedAuctionModel(recentViews: []);
      }
    }

    notifyListeners();
  }

}