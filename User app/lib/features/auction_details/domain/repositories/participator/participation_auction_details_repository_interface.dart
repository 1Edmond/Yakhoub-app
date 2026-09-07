import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class ParticipationAuctionDetailsRepositoryInterface
    implements RepositoryInterface {

  Future<ApiResponseModel> getAuctionProductOverview({
    required String slug,
    String? auctionStatus,
    int productStatus = 0,
  });

  Future<ApiResponseModel> getAuctionBidList({
    required int auctionProductId,
    bool isMyBid = false,
    int offset = 1,
    int limit = 10,
  });
}