import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class VatTaxRepositoryInterface implements RepositoryInterface{
  Future<ApiResponseModel> getVatTaxList();
}