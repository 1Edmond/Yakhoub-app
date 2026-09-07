abstract class AuctionProductQueueServiceInterface {
  Future<dynamic> getAuctionProductQueueList({
    required int offset,
    required String approvalStatus,
    int limit = 10,
  });

  Future<dynamic> deleteAuctionProduct(int id);
}
