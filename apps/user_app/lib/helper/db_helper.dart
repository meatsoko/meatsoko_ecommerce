import 'package:user_app/data/local/cache_response.dart';
import 'package:user_app/main.dart';

class DbHelper{
  static Future<void> insertOrUpdate({required String id, required CacheResponseCompanion data}) async {
    await database.insertCacheResponse(data);
  }


}