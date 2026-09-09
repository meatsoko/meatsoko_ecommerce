import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class VatTaxRepositoryInterface implements RepositoryInterface{
  Future<ApiResponseModel> getVatTaxList();
}