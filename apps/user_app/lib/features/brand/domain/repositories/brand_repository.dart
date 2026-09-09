import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/datasource/remote/dio/dio_client.dart';
import 'package:user_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/data/services/data_sync_service.dart';
import 'package:user_app/features/brand/domain/repositories/brand_repo_interface.dart';
import 'package:user_app/utill/app_constants.dart';

class BrandRepository extends DataSyncService implements BrandRepoInterface {
  final DioClient dioClient;
  BrandRepository(
      {required this.dioClient, required super.dataSyncRepoInterface});

  @override
  Future<ApiResponseModel<T>> getBrandList<T>({int offset = 1, required DataSourceEnum source}) async {
    return await fetchData<T>(
        '${AppConstants.brandUri}&limit=24&offset=$offset', source);
  }

  @override
  Future<ApiResponseModel> getSellerWiseBrandList(String slug) async {
    try {
      final response =
          await dioClient.get('${AppConstants.sellerWiseBrandList}$slug');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }
}
