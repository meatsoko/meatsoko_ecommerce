
import 'package:vendor_app/data/model/response/base/api_response.dart';
import 'package:vendor_app/interface/repository_interface.dart';

abstract class BarcodeRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> barCodeDownLoad(int? id, int quantity);
}