import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class WishListRepositoryInterface implements RepositoryInterface<int>{

  Future<ApiResponseModel> getWishList({int? offset = 1, String? search = ''});

}