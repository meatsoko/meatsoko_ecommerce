enum AuctionEnum {
  all,
  endingSoon,
  trending,
  live,
  upcoming;

  String get auctionStatus {
    switch (this) {
      case AuctionEnum.all:
        return 'all';
      case AuctionEnum.endingSoon:
      case AuctionEnum.trending:
      case AuctionEnum.live:
        return 'live';
      case AuctionEnum.upcoming:
        return 'upcoming';
    }
  }

  String? get sortBy {
    switch (this) {
      case AuctionEnum.endingSoon:
        return 'ending_soon';
      case AuctionEnum.trending:
        return 'trending';
      case AuctionEnum.all:
      case AuctionEnum.live:
      case AuctionEnum.upcoming:
        return null;
    }
  }
}