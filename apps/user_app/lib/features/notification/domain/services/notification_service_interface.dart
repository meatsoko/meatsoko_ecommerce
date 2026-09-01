abstract class NotificationServiceInterface{
  Future<dynamic> getList({int? offset = 1});
  Future<dynamic> seenNotification(int id);
  Future<dynamic> getAuctionList({int limit = 10, int offset = 1});
  Future<dynamic> markAuctionSeen({int? id});
}