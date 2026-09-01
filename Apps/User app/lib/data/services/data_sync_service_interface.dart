import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/model/api_response.dart';

abstract class DataSyncServiceInterface {
  Future<ApiResponseModel<T>> fetchData<T>(String uri, DataSourceEnum source);
}