import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_approval_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_list/domain/services/auction_product_queue_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_list/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class AuctionProductQueueController extends ChangeNotifier {
  final AuctionProductQueueServiceInterface auctionProductQueueServiceInterface;

  AuctionProductQueueController({required this.auctionProductQueueServiceInterface});

  final Map<AuctionApprovalStatus, AuctionProductListModel?> _models = {};

  final Map<AuctionApprovalStatus, bool> _loadingStates = {};
  Map<String, int> _counts = {};

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  int? countFor(AuctionApprovalStatus status) => _counts[status.key];

  AuctionProductListModel? getModel(AuctionApprovalStatus status) {
    return _models[status];
  }

  bool isLoading(AuctionApprovalStatus status) {
    return _loadingStates[status] ?? false;
  }

  Future<void> getAuctionProductList(AuctionApprovalStatus status, int offset, {bool reload = false}) async {
    if (reload || offset == 1) {
      _models[status] = null;
      _loadingStates[status] = true;
      notifyListeners();
    }

    ApiResponseModel apiResponse = await auctionProductQueueServiceInterface.getAuctionProductQueueList(offset: offset, approvalStatus: status.key);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final newData = AuctionProductListModel.fromJson(apiResponse.response!.data);

      if (offset == 1) {
        _models[status] = newData;
        if (newData.counts != null) _counts = newData.counts!;
      } else {
        final existingModel = _models[status];
        existingModel?.products?.addAll(newData.products ?? []);
        existingModel?.offset = newData.offset;
        existingModel?.totalSize = newData.totalSize;
      }

      _loadingStates[status] = false;
    } else {
      _loadingStates[status] = false;
      ApiChecker.checkApi(apiResponse);
    }

    notifyListeners();
  }

  Future<bool> deleteAuctionProduct(int id) async {
    _isDeleting = true;
    notifyListeners();

    try {
      ApiResponseModel apiResponse = await auctionProductQueueServiceInterface.deleteAuctionProduct(id);

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _isDeleting = false;
        notifyListeners();
        return true;
      } else {
        _isDeleting = false;
        ApiChecker.checkApi(apiResponse);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }
}