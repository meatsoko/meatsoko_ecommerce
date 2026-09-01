// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
enum CreatorAuctionDetailsRouteAction {
  payCommission('pay_commission'),
  withdraw('withdraw');

  final String key;
  const CreatorAuctionDetailsRouteAction(this.key);

  static CreatorAuctionDetailsRouteAction? fromKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final action in CreatorAuctionDetailsRouteAction.values) {
      if (action.key == key) return action;
    }
    return null;
  }
}
