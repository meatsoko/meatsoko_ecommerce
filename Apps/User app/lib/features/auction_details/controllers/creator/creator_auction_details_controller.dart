// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/material.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/auction_details/domain/enum/creator/auction_delivery_status_enum.dart';
import 'package:user_app/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:user_app/features/auction_details/domain/models/participator/auction_bid_list_model.dart';
import 'package:user_app/features/auction_details/domain/services/creator/creator_auction_details_service_interface.dart';
import 'package:user_app/features/auction_details/widgets/creator_bidding_list_widget.dart';
import 'package:user_app/helper/api_checker.dart';

class CreatorAuctionDetailsController extends ChangeNotifier {
  final CreatorAuctionDetailsServiceInterface serviceInterface;
  CreatorAuctionDetailsController({required this.serviceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CreatorAuctionProduct? _auctionProduct;
  CreatorAuctionProduct? get auctionProduct => _auctionProduct;

  AuctionBidListModel? _bidListModel;
  AuctionBidListModel? get bidListModel => _bidListModel;

  AuctionWithdrawModel? _auctionWithdraw;
  AuctionWithdrawModel? get auctionWithdraw => _auctionWithdraw;

  AuctionTransaction? _codCommissionTransaction;
  AuctionTransaction? get codCommissionTransaction => _codCommissionTransaction;

  bool _isAdminCommissionPaid = false;
  bool get isAdminCommissionPaid => _isAdminCommissionPaid;

  bool _isCashOnDeliveryCommission = false;
  bool get isCashOnDeliveryCommission => _isCashOnDeliveryCommission;

  double? get commissionAmountToPayToAdmin => _auctionProduct?.adminCommission;

  int? get auctionProductId => _auctionProduct?.id;

  double? get withdrawableAmount => _auctionProduct?.adminCommission;

  List<CreatorBidListItem> _allBids = [];
  List<CreatorBidListItem> get allBids => _allBids;

  bool _hasMoreBids = false;
  bool get hasMoreBids => _hasMoreBids;

  bool _isCollapsed = true;
  bool get isCollapsed => _isCollapsed;

  bool _isBidPaginating = false;
  bool get isBidPaginating => _isBidPaginating;

  bool _isBidListLoading = false;
  bool get isBidListLoading => _isBidListLoading;

  int _bidOffset = 1;

  Future<void> getAuctionDetails(BuildContext context, String slug) async {
    _isLoading = true;
    notifyListeners();

    final ApiResponseModel response = await serviceInterface.getAuctionDetails(slug: slug);

    _isLoading = false;

    if (!response.isSuccess && context.mounted) {
      ApiChecker.checkApi(response);
    }

    notifyListeners();
  }

  Future<bool> updateDeliveryStatus(int productId, AuctionDeliveryStatus status) async {
    final ApiResponseModel response = await serviceInterface.updateDeliveryStatus(productId: productId, status: status.value);
    return response.isSuccess;
  }

  Future<bool> uploadTrackingUrl(int productId, String url) async {
    final ApiResponseModel response = await serviceInterface.uploadTrackingUrl(productId: productId, url: url);
    return response.isSuccess;
  }

  Future<void> getAuctionBidList({required int productId}) async {
    _isBidListLoading = true;
    _bidOffset = 1;
    notifyListeners();

    final ApiResponseModel response = await serviceInterface.getBidList(productId: productId, offset: _bidOffset);

    _isBidListLoading = false;
    if (!response.isSuccess) {
      _allBids = [];
      _hasMoreBids = false;
    }
    notifyListeners();
  }

  Future<void> loadMoreBids({required int productId}) async {
    _isBidPaginating = true;
    notifyListeners();

    _bidOffset += 1;
    final ApiResponseModel response = await serviceInterface.getBidList(productId: productId, offset: _bidOffset);

    _isBidPaginating = false;
    if (!response.isSuccess) {
      _hasMoreBids = false;
    }
    notifyListeners();
  }

  void collapseBids() {
    _isCollapsed = true;
    notifyListeners();
  }
}
