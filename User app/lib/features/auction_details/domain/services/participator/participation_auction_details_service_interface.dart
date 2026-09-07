abstract class ParticipationAuctionDetailsServiceInterface {

  Future<dynamic> getAuctionProductOverview({
    required String slug,
    String? auctionStatus,
    int productStatus = 0,
  });

  Future<dynamic> getAuctionBidList({
    required int auctionProductId,
    bool isMyBid = false,
    int offset = 1,
    int limit = 10,
  });
}