import 'package:user_app/common/enums/data_source_enum.dart';
import 'package:user_app/data/model/api_response.dart';
import 'package:user_app/features/cart/domain/models/cart_model.dart';
import 'package:user_app/features/product/domain/models/product_model.dart';

abstract class CartServiceInterface{

  Future<dynamic> getCartList({String? couponCode});

  Future<dynamic> delete(int id);

  Future<dynamic> addToCartListData(CartModelBody cart, List<ChoiceOptions> choiceOptions, List<int>? variationIndexes, int buyNow, int? shippingMethodExist, int? shippingMethodId);

  Future<dynamic> updateQuantity(int? key,int quantity);

  Future<dynamic> addRemoveCartSelectedItem(Map<String, dynamic> data);

  Future<dynamic> restockRequest(CartModelBody cart, List<ChoiceOptions> choiceOptions, List<int>? variationIndexes, int buyNow, int? shippingMethodExist, int? shippingMethodId);

  Future<ApiResponseModel<T>> getCartData<T>({required DataSourceEnum source});

  Future<dynamic> mergeGuestCart();

}