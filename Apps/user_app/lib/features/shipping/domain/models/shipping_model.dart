import 'package:user_app/features/shipping/domain/models/shipping_method_model.dart';

class ShippingModel{
  int? shippingIndex;
  String? groupId;
  List<ShippingMethodModel>? shippingMethodList;

  ShippingModel(this.shippingIndex, this.groupId, this.shippingMethodList);
}