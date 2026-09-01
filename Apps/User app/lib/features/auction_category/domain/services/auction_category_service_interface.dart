import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/model/api_response.dart';

abstract class AuctionCategoryServiceInterface {
  Future<ApiResponseModel<T>> getList<T>({required DataSourceEnum source});

  Future<ApiResponseModel<T>> getCategoryProductList<T>({
    required int categoryId,
    required int offset,
    required DataSourceEnum source,
    String searchProduct,
  });

}
