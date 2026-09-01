import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/model/api_response.dart';

abstract class BannerServiceInterface{
  Future<ApiResponseModel<T>> getList<T>({required DataSourceEnum source});

}