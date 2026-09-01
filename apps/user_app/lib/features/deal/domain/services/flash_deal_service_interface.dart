
abstract class FlashDealServiceInterface {

  Future<dynamic> getFlashDeal();
  Future<dynamic> get(String productID, {int offset = 1, int limit = 10});

}