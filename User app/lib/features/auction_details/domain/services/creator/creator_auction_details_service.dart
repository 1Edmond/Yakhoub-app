import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/enum/creator/auction_delivery_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/creator/creator_auction_details_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/creator/creator_auction_details_service_interface.dart';

class CreatorAuctionDetailsService implements CreatorAuctionDetailsServiceInterface {
  final CreatorAuctionDetailsRepositoryInterface repoInterface;

  CreatorAuctionDetailsService({required this.repoInterface});

  @override
  Future getAuctionDetails(String slug) async {
    return await repoInterface.getAuctionDetails(slug);
  }

  @override
  Future getAuctionBidList({
    required int auctionProductId,
    int offset = 1,
    int limit = 10,
  }) async {
    return await repoInterface.getAuctionBidList(auctionProductId: auctionProductId, offset: offset, limit: limit);
  }

  @override
  Future uploadTrackingUrl(int auctionProductId, String trackingUrl) async {
    return await repoInterface.uploadTrackingUrl(auctionProductId, trackingUrl);
  }

  @override
  Future<dynamic> updateDeliveryStatus(int auctionProductId, AuctionDeliveryStatus status) async {
    return await repoInterface.updateDeliveryStatus(auctionProductId, status);
  }
}