
class ImageResponseModel {
  bool? success;
  String? message;
  String? data;

  ImageResponseModel({this.success, this.message, this.data});

  ImageResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      data = rawData['data']?.toString();
    } else if (rawData is String) {
      data = rawData;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['data'] = this.data;
    return data;
  }
}