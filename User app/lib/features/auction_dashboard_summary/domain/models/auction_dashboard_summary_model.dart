class AuctionDashboardSummaryModel {
  int? totalMyBids;
  int? totalMySavedAuctions;
  int? totalMyAuctions;
  int? totalMyAuctionPending;

  AuctionDashboardSummaryModel({
    this.totalMyBids,
    this.totalMySavedAuctions,
    this.totalMyAuctions,
    this.totalMyAuctionPending,
  });

  factory AuctionDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return AuctionDashboardSummaryModel(
      totalMyBids: json['total_my_bids'],
      totalMySavedAuctions: json['total_my_saved_auctions'],
      totalMyAuctions: json['total_my_auctions'],
      totalMyAuctionPending: json['total_my_auction_pending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_my_bids': totalMyBids,
      'total_my_saved_auctions': totalMySavedAuctions,
      'total_my_auctions': totalMyAuctions,
      'total_my_auction_pending': totalMyAuctionPending,
    };
  }
}
