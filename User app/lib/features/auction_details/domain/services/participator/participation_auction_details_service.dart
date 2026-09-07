import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/participator/participation_auction_details_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/participator/participation_auction_details_service_interface.dart';

class ParticipationAuctionDetailsService implements ParticipationAuctionDetailsServiceInterface {

  final ParticipationAuctionDetailsRepositoryInterface participationAuctionDetailsRepositoryInterface;

  ParticipationAuctionDetailsService({
    required this.participationAuctionDetailsRepositoryInterface,
  });

  @override
  Future getAuctionProductOverview({
    required String slug,
    String? auctionStatus,
    int productStatus = 0,
  }) async {
    return await participationAuctionDetailsRepositoryInterface.getAuctionProductOverview(slug: slug, auctionStatus: auctionStatus, productStatus: productStatus);
  }

  @override
  Future getAuctionBidList({
    required int auctionProductId,
    bool isMyBid = false,
    int offset = 1,
    int limit = 10,
  }) async {
    return await participationAuctionDetailsRepositoryInterface.getAuctionBidList(
      auctionProductId: auctionProductId, isMyBid: isMyBid, offset: offset, limit: limit);
  }
}