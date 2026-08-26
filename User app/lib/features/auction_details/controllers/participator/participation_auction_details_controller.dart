// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_bid_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/participation_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/participator/participation_auction_details_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class ParticipationAuctionDetailsController extends ChangeNotifier {
  final ParticipationAuctionDetailsServiceInterface participationAuctionDetailsServiceInterface;
  ParticipationAuctionDetailsController({required this.participationAuctionDetailsServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ParticipationAuctionDetailsModel? _auctionDetails;
  ParticipationAuctionDetailsModel? get auctionDetails => _auctionDetails;

  List<AuctionBidItem> _allBids = [];
  List<AuctionBidItem> get allBids => _allBids;

  bool _hasMoreBids = false;
  bool get hasMoreBids => _hasMoreBids;

  bool _isCollapsed = true;
  bool get isCollapsed => _isCollapsed;

  bool _isBidPaginating = false;
  bool get isBidPaginating => _isBidPaginating;

  bool _isBidListLoading = false;
  bool get isBidListLoading => _isBidListLoading;

  int _bidOffset = 1;

  Future<void> getAuctionProductOverview(BuildContext context, {required String slug, String? auctionStatus, bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    final ApiResponseModel response = await participationAuctionDetailsServiceInterface.getAuctionProductOverview(
      slug: slug,
      auctionStatus: auctionStatus,
    );

    _isLoading = false;

    if (!response.isSuccess && context.mounted) {
      ApiChecker.checkApi(response);
    }

    notifyListeners();
  }

  Future<void> getAuctionBidList({required int productId, bool isMyBid = false}) async {
    _isBidListLoading = true;
    _bidOffset = 1;
    notifyListeners();

    final ApiResponseModel response = await participationAuctionDetailsServiceInterface.getAuctionBidList(
      productId: productId,
      offset: _bidOffset,
      isMyBid: isMyBid,
    );

    _isBidListLoading = false;
    if (!response.isSuccess) {
      _allBids = [];
      _hasMoreBids = false;
    }
    notifyListeners();
  }

  Future<void> loadMoreBids({required int productId, bool isMyBid = false}) async {
    _isBidPaginating = true;
    notifyListeners();

    _bidOffset += 1;
    final ApiResponseModel response = await participationAuctionDetailsServiceInterface.getAuctionBidList(
      productId: productId,
      offset: _bidOffset,
      isMyBid: isMyBid,
    );

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
