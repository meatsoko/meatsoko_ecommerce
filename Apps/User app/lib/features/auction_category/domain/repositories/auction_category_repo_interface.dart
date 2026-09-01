// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class AuctionCategoryRepoInterface extends RepositoryInterface {
  Future<ApiResponseModel<T>> getCategoryProductList<T>({
    required int categoryId,
    required int offset,
    required DataSourceEnum source,
    String searchProduct = '',
  });

  Future<ApiResponseModel<T>> getAuctionCategoryList<T>({required DataSourceEnum source});
}
