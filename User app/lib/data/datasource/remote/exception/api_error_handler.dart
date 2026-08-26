
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/error_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class ApiErrorHandler {
  static dynamic _field(dynamic data, String key) => data is Map ? data[key] : null;

  static ErrorResponse? _errorResponseFrom(dynamic data) =>
      data is Map<String, dynamic> ? ErrorResponse.fromJson(data) : null;

  static dynamic getMessage(dynamic error) {
    dynamic errorDescription = "";
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              errorDescription = "Request to API server was cancelled";
              break;
            case DioExceptionType.connectionTimeout:
              errorDescription = "Connection timeout with API server";
              break;
            case DioExceptionType.sendTimeout:
              errorDescription = "Send timeout";
              break;
            case DioExceptionType.receiveTimeout:
              errorDescription = "Receive timeout in connection with API server";
              break;
            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {

                case 403:
                  if(_field(error.response!.data, 'errors') != null){
                    final errorResponse = _errorResponseFrom(error.response!.data);
                    errorDescription = errorResponse?.errors?[0].message;
                  }else{
                    errorDescription = _field(error.response!.data, 'message');
                  }

                  if (kDebugMode) {
                    print("=================403=============>>$errorDescription");
                    print("=================403=============>>${error.response!.data}");
                  }

                  break;
                case 401:
                  Provider.of<AuthController>(Get.context!,listen: false).clearSharedData();
                  if(_field(error.response!.data, 'errors') != null) {
                    final errorResponse = _errorResponseFrom(error.response!.data);
                    errorDescription = errorResponse?.errors?[0].message;
                  } else{
                    errorDescription = _field(error.response!.data, 'message');
                  }
                  break;
                case 404:
                  break;
                case 400:
                  if(_field(error.response!.data, 'errors') != null){
                    final errorResponse = _errorResponseFrom(error.response!.data);
                    errorDescription = errorResponse?.errors?[0].message;
                  } else{
                    errorDescription = _field(error.response!.data, 'message') ?? '';
                  }
                  break;
                case 422:
                  if(_field(error.response!.data, 'errors') != null){
                    final errorResponse = _errorResponseFrom(error.response!.data);
                    errorDescription = errorResponse?.errors?[0].message;
                  } else{
                    errorDescription = _field(error.response!.data, 'message') ?? '';
                  }
                  break;
                case 500:
                  if (kDebugMode) {
                    print("-----------500------------->>${error.response!.data}");
                  }
                  errorDescription = 'Internal server error';
                case 503:
                  if(_field(error.response!.data, 'message') != null){
                    errorDescription = _field(error.response!.data, 'message');
                  }
                case 429:
                  errorDescription = error.response!.statusMessage;
                  break;
                default:
                  final errorResponse = _errorResponseFrom(error.response!.data);
                  if (errorResponse?.errors != null && errorResponse!.errors!.isNotEmpty) {
                    errorDescription = errorResponse;
                  } else {errorDescription = "Failed to load data - status code: ${error.response!.statusCode}";
                  }
              }
              break;
            case DioExceptionType.badCertificate:
              // TODO: Handle this case.
              break;
            case DioExceptionType.connectionError:
              // TODO: Handle this case.
              break;
            case DioExceptionType.unknown:
              errorDescription = "Request to API call limit excited ";
              break;
            case DioExceptionType.transformTimeout:
              errorDescription = "Transform timeout in connection with API server";
              break;
          }
        } else {
          errorDescription = "Unexpected error occured";
        }
      } on FormatException catch (e) {
        errorDescription = e.toString();
      }
    } else {
      errorDescription = "is not a subtype of exception";
    }
    return errorDescription;
  }
}
