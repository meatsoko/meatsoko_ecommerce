import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class NotificationRepositoryInterface implements RepositoryInterface{
  Future<dynamic> seenNotification(int id);
  Future<dynamic> getAuctionList({int limit = 10, int offset = 1});
  Future<dynamic> markAuctionSeen({int? id});
}