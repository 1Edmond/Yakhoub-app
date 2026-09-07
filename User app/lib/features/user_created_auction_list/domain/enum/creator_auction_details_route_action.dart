enum CreatorAuctionDetailsRouteAction {
  payCommission,
  withdraw;

  String get key => name;

  static CreatorAuctionDetailsRouteAction? fromKey(String? key) {
    if (key == null) return null;
    return CreatorAuctionDetailsRouteAction.values.where((e) => e.key == key).firstOrNull;
  }
}