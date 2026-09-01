import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/datasource/remote/dio/dio_client.dart';
import 'package:user_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/data/services/data_sync_service.dart';
import 'package:user_app/features/auction_home/domain/auction_enum.dart';
import 'package:user_app/features/auction_home/domain/repositories/auction_home_repo_interface.dart';
import 'package:user_app/features/auth/controllers/auth_controller.dart';
import 'package:user_app/main.dart';
import 'package:user_app/utill/app_constants.dart';
import 'package:provider/provider.dart';

class AuctionHomeRepository extends DataSyncService implements AuctionHomeRepoInterface {
  final DioClient? dioClient;
  AuctionHomeRepository({required this.dioClient, required super.dataSyncRepoInterface});

  @override
  Future<ApiResponseModel<T>> getAuctionHomeSection<T>({
    required AuctionEnum section,
    required DataSourceEnum source,
    required int offset,
    int? categoryId,
    int? ownerId,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': 10,
      'offset': offset,
      'auction_status': section.auctionStatus,
      if (categoryId != null) 'category_id': categoryId,
      if (ownerId != null) 'author_id': ownerId,
      if (section.sortBy != null) 'sort_by': section.sortBy,
    };

    final String url = Uri(path: AppConstants.customerAuctionProductListUri, queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString()))).toString();

    return await fetchData<T>(url, source);
  }

  @override
  Future<ApiResponseModel> getRecentlyViewedAuctionList({int offset = 1}) async {
    dioClient!.dio!.options.headers = {
      'Authorization': 'Bearer ${Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}'
    };

    try {
      final response = await dioClient!.get('${AppConstants.auctionRecentViewsUri}?limit=10&offset=$offset');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getList({int? offset = 1}) {
    throw UnimplementedError();
  }
}
