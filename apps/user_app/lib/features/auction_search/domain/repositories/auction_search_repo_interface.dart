import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class AuctionSearchRepoInterface extends RepositoryInterface {

  Future<ApiResponseModel> getAuctionSearchList({
    required int offset,
    String auctionStatus = '',
    String search = '',
    int limit = 10,
    Map<String, dynamic> extraParams = const {},
  });

  Future<void> saveAuctionSearchName(String searchText);

  List<String> getSavedAuctionSearchNames();

  Future<bool> clearSavedAuctionSearchNames();

  Future<ApiResponseModel> getAuctionSuggestionProductName(String name);

  Future<ApiResponseModel> getAuctionPopularTags({int limit = 10});

}
