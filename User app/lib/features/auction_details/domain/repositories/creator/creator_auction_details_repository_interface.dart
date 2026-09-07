import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/enum/creator/auction_delivery_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class CreatorAuctionDetailsRepositoryInterface implements RepositoryInterface {
  Future<ApiResponseModel> getAuctionDetails(String slug);

  Future<ApiResponseModel> getAuctionBidList({required int auctionProductId, int offset = 1, int limit = 10});
  Future<ApiResponseModel> uploadTrackingUrl(int auctionProductId, String trackingUrl);
  Future<ApiResponseModel> updateDeliveryStatus(int auctionProductId, AuctionDeliveryStatus status);
}