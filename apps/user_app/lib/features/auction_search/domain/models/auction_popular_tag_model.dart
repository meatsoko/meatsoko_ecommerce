class AuctionPopularTagModel {
  final List<AuctionPopularTag> popularTags;

  const AuctionPopularTagModel({required this.popularTags});

  factory AuctionPopularTagModel.fromJson(Map<String, dynamic> json) {
    return AuctionPopularTagModel(
      popularTags: (json['popular_tags'] as List).map((e) => AuctionPopularTag.fromJson(e)).toList(),
    );
  }
}

class AuctionPopularTag {
  final int id;
  final String tag;
  final String createdAt;
  final String updatedAt;

  const AuctionPopularTag({
    required this.id,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuctionPopularTag.fromJson(Map<String, dynamic> json) {
    return AuctionPopularTag(
      id: json['id'],
      tag: json['tag'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}