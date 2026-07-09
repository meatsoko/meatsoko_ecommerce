import 'package:flutter_sixvalley_ecommerce/data/local/cache_response.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';

class DbHelper{
  static Future<void> insertOrUpdate({required String id, required CacheResponseCompanion data}) async {
    await database.insertCacheResponse(data);
  }


}