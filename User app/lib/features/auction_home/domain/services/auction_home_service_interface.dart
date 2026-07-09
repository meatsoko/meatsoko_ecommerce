import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/auction_enum.dart';

abstract class AuctionHomeServiceInterface {
  Future<ApiResponseModel<T>> getAuctionHomeSection<T>({
    required AuctionEnum section,
    required DataSourceEnum source,
    required int offset,
    int? categoryId,
    int? ownerId,
  });

  Future<ApiResponseModel> getRecentlyViewedAuctionList({int offset = 1});
}
