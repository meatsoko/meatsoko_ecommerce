enum AuctionCardState { live, upcoming, ended }

extension AuctionCardStateX on AuctionCardState {
  bool get showBadge => this == AuctionCardState.live || this == AuctionCardState.upcoming;
}

enum AuctionCurrentStatus {
  upcoming('upcoming'),
  live('live');

  final String label;

  const AuctionCurrentStatus(this.label);

  static AuctionCurrentStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return AuctionCurrentStatus.values.firstWhere(
        (e) => e.label.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  bool get isUpcoming => this == AuctionCurrentStatus.upcoming;
  bool get isLive => this == AuctionCurrentStatus.live;
}

enum AuctionParticipationStatus {
  all('all'),
  upcoming('upcoming'),
  participated('participated'),
  live('live'),
  won('won'),
  claimed('claimed'),
  lost('lost'),
  claimExpiredLost('claim_expired_lost'),
  finalizing('finalizing');

  final String label;

  const AuctionParticipationStatus(this.label);

  static AuctionParticipationStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    return AuctionParticipationStatus.values.firstWhere((e) =>
      e.label.toLowerCase() == value.toLowerCase() ||
          e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AuctionParticipationStatus.finalizing,
    );
  }

  String toJson() => label;

  bool get isAll => this == AuctionParticipationStatus.all;
  bool get isFinalizing => this == AuctionParticipationStatus.finalizing;

  bool get isParticipated => this == AuctionParticipationStatus.participated;

  bool get isLive => this == AuctionParticipationStatus.live;

  bool get isWon => this == AuctionParticipationStatus.won;

  bool get isClaimed => this == AuctionParticipationStatus.claimed;

  bool get isLost => this == AuctionParticipationStatus.lost;

  bool get isClaimExpiredLost => this == AuctionParticipationStatus.claimExpiredLost;

  bool get isUpcoming => this == AuctionParticipationStatus.upcoming;
}