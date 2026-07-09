import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/domain/repositories/auction_category_repo_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/domain/services/auction_category_service_interface.dart';

class AuctionCategoryService implements AuctionCategoryServiceInterface {
  AuctionCategoryRepoInterface auctionCategoryRepoInterface;
  AuctionCategoryService({required this.auctionCategoryRepoInterface});

  @override
  Future<ApiResponseModel<T>> getList<T>({required DataSourceEnum source}) async {
    return await auctionCategoryRepoInterface.getAuctionCategoryList(source: source);
  }

  @override
  Future<ApiResponseModel<T>> getCategoryProductList<T>({
    required int categoryId,
    required int offset,
    required DataSourceEnum source,
    String searchProduct = '',
  }) async {
    return await auctionCategoryRepoInterface.getCategoryProductList(categoryId: categoryId, offset: offset, source: source, searchProduct: searchProduct);
  }
}
