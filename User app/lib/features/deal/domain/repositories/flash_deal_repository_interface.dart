import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class FlashDealRepositoryInterface implements RepositoryInterface{

  Future<dynamic> getFlashDeal();
  @override
  Future<dynamic> get(String productID, {int offset = 1, int limit = 10});
}