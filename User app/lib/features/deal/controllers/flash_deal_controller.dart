import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/local/cache_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/domain/models/flash_deal_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/domain/services/flash_deal_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:intl/intl.dart';

class FlashDealController extends ChangeNotifier {
  final FlashDealServiceInterface flashDealServiceInterface;
  FlashDealController({required this.flashDealServiceInterface});

  FlashDealModel? _flashDeal;
  final List<Product> _flashDealList = [];
  Duration? _duration;
  Timer? _timer;
  FlashDealModel? get flashDeal => _flashDeal;
  List<Product> get flashDealList => _flashDealList;
  Duration? get duration => _duration;
  int? _currentIndex;
  int? get currentIndex => _currentIndex;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  int? _flashDealProductTotalSize;
  int? _flashDealProductOffset;
  int? get flashDealProductTotalSize => _flashDealProductTotalSize;
  int? get flashDealProductOffset => _flashDealProductOffset;

  Future<void> getFlashDealList(bool reload, bool notify) async {


    var localData =  await database.getCacheResponseById(AppConstants.flashDealUri);
    CacheResponseData? localData2;

    if(localData != null) {

      _flashDeal = FlashDealModel.fromJson(jsonDecode(localData.response));

      if(_flashDeal!.id != null) {
        DateTime endTime = DateFormat("yyyy-MM-dd").parse(_flashDeal!.endDate!).add(const Duration(days: 2));
        _duration = endTime.difference(DateTime.now());
        _timer?.cancel();
        _timer = null;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _duration = _duration! - const Duration(seconds: 1);
          notifyListeners();
        });

        localData2 =  await database.getCacheResponseById(AppConstants.flashDealProductUri);

        if(localData2 != null) {
          _flashDealList.clear();
          try {
            final ProductModel cached = ProductModel.fromJson(jsonDecode(localData2.response));
            _flashDealList.addAll(cached.products ?? []);
            _flashDealProductTotalSize = cached.totalSize;
            _flashDealProductOffset = cached.offset;
          } catch (_) {
            // stale cache in old list-only format — will be refreshed from API
          }
          _currentIndex = 0;
        }
      }
      _isLoading = false;
      notifyListeners();
    }



    if (_flashDealList.isEmpty || reload) {

      ApiResponseModel apiResponse = await flashDealServiceInterface.getFlashDeal();
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _flashDeal = FlashDealModel.fromJson(apiResponse.response!.data);

        print("----12234----00>>${apiResponse.response!.data}");

        if(localData != null) {
          await database.updateCacheResponse(AppConstants.flashDealUri, CacheResponseCompanion(
            endPoint: const Value(AppConstants.flashDealUri),
            header: Value(jsonEncode(apiResponse.response!.headers.map)),
            response: Value(jsonEncode(apiResponse.response!.data)),
          ));
        } else {
          await database.insertCacheResponse(
            CacheResponseCompanion(
              endPoint: const Value(AppConstants.flashDealUri),
              header: Value(jsonEncode(apiResponse.response!.headers.map)),
              response: Value(jsonEncode(apiResponse.response!.data)),
            ),
          );
        }

        if(_flashDeal!.id != null) {
          DateTime endTime = DateFormat("yyyy-MM-dd").parse(_flashDeal!.endDate!).add(const Duration(days: 2));
          _duration = endTime.difference(DateTime.now());
          _timer?.cancel();
          _timer = null;
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            _duration = _duration! - const Duration(seconds: 1);
            notifyListeners();

          });

          ApiResponseModel megaDealResponse = await flashDealServiceInterface.get(
            _flashDeal!.id.toString(), offset: 1, limit: 10,
          );

          if (megaDealResponse.response != null && megaDealResponse.response!.statusCode == 200) {

            final ProductModel productModel = ProductModel.fromJson(megaDealResponse.response!.data);
            _flashDealList.clear();
            _flashDealList.addAll(productModel.products ?? []);
            _flashDealProductTotalSize = productModel.totalSize;
            _flashDealProductOffset = productModel.offset;
            _currentIndex = 0;

            if(localData2 != null) {
              await database.updateCacheResponse(AppConstants.flashDealProductUri, CacheResponseCompanion(
                endPoint: const Value(AppConstants.flashDealProductUri),
                header: Value(jsonEncode(megaDealResponse.response!.headers.map)),
                response: Value(jsonEncode(megaDealResponse.response!.data)),
              ));
            } else {
              await database.insertCacheResponse(
                CacheResponseCompanion(
                  endPoint: const Value(AppConstants.flashDealProductUri),
                  header: Value(jsonEncode(megaDealResponse.response!.headers.map)),
                  response: Value(jsonEncode(megaDealResponse.response!.data)),
                ),
              );
            }
          } else {
            ApiChecker.checkApi( megaDealResponse);
          }
          _isLoading = false;
          notifyListeners();
        } else {
          notifyListeners();
        }
      } else {
        ApiChecker.checkApi( apiResponse);
      }
    }
  }

  Future<void> getFlashDealProducts(int offset) async {
    if (_flashDeal?.id == null) return;
    final ApiResponseModel response = await flashDealServiceInterface.get(
      _flashDeal!.id.toString(), offset: offset, limit: 10,
    );
    if (response.response != null && response.response!.statusCode == 200) {
      final ProductModel productModel = ProductModel.fromJson(response.response!.data);
      _flashDealList.addAll(productModel.products ?? []);
      _flashDealProductTotalSize = productModel.totalSize;
      _flashDealProductOffset = productModel.offset;
      notifyListeners();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
