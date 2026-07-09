import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/repository/vat_tax_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class VatTaxRepository implements VatTaxRepositoryInterface{
  final DioClient? dioClient;
  VatTaxRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getVatTaxList() async {
    try {
      final response = await dioClient!.get(AppConstants.getTaxVatList);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<dynamic> add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<dynamic> get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future<dynamic> update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }
}