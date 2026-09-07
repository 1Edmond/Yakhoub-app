abstract class UserCreatedAuctionListServiceInterface {
  Future<dynamic> getMyAuctionList({required int offset, required String auctionStatus, int limit = 10, bool includeCounts = false});
}