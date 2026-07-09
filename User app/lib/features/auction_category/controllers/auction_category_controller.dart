import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/domain/services/auction_category_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/domain/models/auction_category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/helper/data_sync_helper.dart';

class AuctionCategoryController extends ChangeNotifier {
  final AuctionCategoryServiceInterface? auctionCategoryServiceInterface;
  AuctionCategoryController({required this.auctionCategoryServiceInterface});

  final List<AuctionCategoryModel> _categoryList = [];
  int? _categorySelectedIndex;
  final Map<int, AuctionProductListModel> _categoryProducts = {};
  final Set<int> _fetchingCategoryIds = {};
  bool _isCategoryListLoading = true;

  List<AuctionCategoryModel> get categoryList => _categoryList;
  int? get categorySelectedIndex => _categorySelectedIndex;
  bool get isCategoryListLoading => _isCategoryListLoading;

  AuctionProductListModel? categoryProductsFor(int categoryId) => _categoryProducts[categoryId];

  void clearCategoryProductFor(int categoryId) {
    _categoryProducts.remove(categoryId);
    _fetchingCategoryIds.remove(categoryId);
  }

  Future<void> fetchWithCache() async {
    await getCategoryList(false);
    await Future.wait(
      _categoryList.where((c) => c.id != null).map((c) => getCategoryProducts(c.id!, 1)),
    );
  }

  Future<void> getCategoryList(bool reload) async {
    if (_categoryList.isEmpty || reload) {
      _isCategoryListLoading = true;
      await DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => auctionCategoryServiceInterface!.getList(source: DataSourceEnum.local),
        fetchFromClient: () => auctionCategoryServiceInterface!.getList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          if (data != null) {
            _categoryList.clear();
            data.forEach((category) => _categoryList.add(AuctionCategoryModel.fromJson(category)));
            _categorySelectedIndex = 0;
            notifyListeners();
          }
        },
      );
      _isCategoryListLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCategoryProducts(int categoryId, int offset, {String searchProduct = ''}) async {
    if (offset == 1) {
      if (_fetchingCategoryIds.contains(categoryId)) return;
      if (_categoryProducts.containsKey(categoryId)) return;

      _fetchingCategoryIds.add(categoryId);
      _categoryProducts[categoryId] = AuctionProductListModel(products: null);
      notifyListeners();

      await DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => auctionCategoryServiceInterface!.getCategoryProductList(
          categoryId: categoryId,
          offset: offset,
          source: DataSourceEnum.local,
          searchProduct: searchProduct,
        ),
        fetchFromClient: () => auctionCategoryServiceInterface!.getCategoryProductList(
          categoryId: categoryId,
          offset: offset,
          source: DataSourceEnum.client,
          searchProduct: searchProduct,
        ),
        onResponse: (data, source) {
          try {
            _categoryProducts[categoryId] = AuctionProductListModel.fromJson(data);
          } catch (_) {
            _categoryProducts[categoryId] = AuctionProductListModel(products: [], offset: 1);
          }
          notifyListeners();
        },
      );

      _fetchingCategoryIds.remove(categoryId);

    } else {
      final ApiResponseModel? apiResponse = await auctionCategoryServiceInterface?.getCategoryProductList<Response>(
        categoryId: categoryId,
        offset: offset,
        source: DataSourceEnum.client,
        searchProduct: searchProduct,
      );

      if (apiResponse?.response?.statusCode == 200) {
        final parsed = AuctionProductListModel.fromJson(apiResponse?.response?.data);
        _categoryProducts[categoryId]?.totalSize = parsed.totalSize;
        _categoryProducts[categoryId]?.offset = parsed.offset;
        _categoryProducts[categoryId]?.products?.addAll(parsed.products ?? []);
      } else {
        ApiChecker.checkApi(apiResponse!);
      }
      notifyListeners();
    }
  }

  void onChangeSelectedIndex(int selectedIndex, {bool isUpdate = true}) {
    _categorySelectedIndex = selectedIndex;
    if (isUpdate) notifyListeners();
  }
}
