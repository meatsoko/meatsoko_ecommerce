class CommissionPayResponseModel {
  final String? message;
  final String? redirectLink;

  CommissionPayResponseModel({this.message, this.redirectLink});

  CommissionPayResponseModel.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        redirectLink = json['redirect_link'];
}
