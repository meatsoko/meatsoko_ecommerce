// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/material.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/user_created_auction_list/domain/enum/user_created_auction_status_enum.dart';
import 'package:user_app/features/user_created_auction_list/domain/models/user_created_auction_list_model.dart';
import 'package:user_app/features/user_created_auction_list/domain/services/user_created_auction_list_service_interface.dart';

class UserCreatedAuctionListController extends ChangeNotifier {
  final UserCreatedAuctionListServiceInterface userCreatedAuctionListServiceInterface;
  UserCreatedAuctionListController({required this.userCreatedAuctionListServiceInterface});

  final Map<UserCreatedAuctionStatusEnum, UserCreatedAuctionListModel> _models = {};
  final Map<UserCreatedAuctionStatusEnum, bool> _loading = {};

  AuctionCounts? _counts;
  AuctionCounts? get counts => _counts;

  bool isLoading(UserCreatedAuctionStatusEnum status) => _loading[status] ?? false;

  UserCreatedAuctionListModel? getModel(UserCreatedAuctionStatusEnum status) => _models[status];

  Future<void> getMyAuctionList(UserCreatedAuctionStatusEnum status, int offset, {bool reload = false}) async {
    _loading[status] = true;
    if (reload) _models.remove(status);
    notifyListeners();

    final ApiResponseModel response = await userCreatedAuctionListServiceInterface.getMyAuctionList(
      status: status.key,
      offset: offset,
    );

    _loading[status] = false;

    if (response.isSuccess && response.response != null) {
      // Stub service never actually succeeds; kept for shape completeness.
    }

    notifyListeners();
  }
}
