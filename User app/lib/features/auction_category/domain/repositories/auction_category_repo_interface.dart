// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class AuctionCategoryRepoInterface extends RepositoryInterface {
  Future<ApiResponseModel<T>> getCategoryProductList<T>({
    required int categoryId,
    required int offset,
    required DataSourceEnum source,
    String searchProduct = '',
  });

  Future<ApiResponseModel<T>> getAuctionCategoryList<T>({required DataSourceEnum source});
}
