import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/auction_home/domain/auction_enum.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class AuctionHomeRepoInterface extends RepositoryInterface {
  Future<ApiResponseModel<T>> getAuctionHomeSection<T>({
    required AuctionEnum section,
    required DataSourceEnum source,
    required int offset,
    int? categoryId,
    int? ownerId,
  });

  Future<ApiResponseModel> getRecentlyViewedAuctionList({int offset = 1});
}
