import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class BannerRepositoryInterface<T> implements RepositoryInterface{
  Future<ApiResponseModel<T>> getBannerList<T>({required DataSourceEnum source});


}