import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/enum/creator/auction_delivery_status_enum.dart';

abstract class CreatorAuctionDetailsServiceInterface {
  Future<dynamic> getAuctionDetails(String slug);

  Future<dynamic> getAuctionBidList({
    required int auctionProductId,
    int offset = 1,
    int limit = 10,
  });

  Future<dynamic> uploadTrackingUrl(int auctionProductId, String trackingUrl);

  Future<dynamic> updateDeliveryStatus(int auctionProductId, AuctionDeliveryStatus status);
}