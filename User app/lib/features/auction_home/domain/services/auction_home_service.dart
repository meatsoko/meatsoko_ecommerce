import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/repositories/auction_home_repo_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/services/auction_home_service_interface.dart';

class AuctionHomeService implements AuctionHomeServiceInterface {
  AuctionHomeRepoInterface auctionHomeRepoInterface;
  AuctionHomeService({required this.auctionHomeRepoInterface});

  @override
  Future<ApiResponseModel<T>> getAuctionHomeSection<T>({
    required AuctionEnum section,
    required DataSourceEnum source,
    required int offset,
    int? categoryId,
    int? ownerId,
  }) async {
    return await auctionHomeRepoInterface.getAuctionHomeSection(
      section: section,
      source: source,
      offset: offset,
      categoryId: categoryId,
      ownerId: ownerId,
    );
  }

  @override
  Future<ApiResponseModel> getRecentlyViewedAuctionList({int offset = 1}) async {
    return await auctionHomeRepoInterface.getRecentlyViewedAuctionList(offset: offset);
  }
}
