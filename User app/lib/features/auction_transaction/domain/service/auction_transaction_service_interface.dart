abstract class AuctionTransactionServiceInterface {
  Future<dynamic> getAuctionTransactionList({
    int? searchAuctionId,
    int limit = 10,
    int offset = 1,
    String? filterBy,
    String? filterDurationType,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<dynamic> getSalesReport({required String dateType, String? startDate, String? endDate});
}
