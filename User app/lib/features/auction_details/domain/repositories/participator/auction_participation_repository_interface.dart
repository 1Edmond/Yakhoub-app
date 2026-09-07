import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_bid_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_entry_fee_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_save_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class AuctionParticipationRepositoryInterface implements RepositoryInterface {

  Future<ApiResponseModel> payAuctionEntryFee({
    required AuctionEntryFeeRequestModel entryFeeRequest,
  });

  Future<ApiResponseModel> placeAuctionBid({
    required AuctionBidRequestModel bidRequest,
  });

  Future<ApiResponseModel> withdrawAuctionBid({
    required int auctionProductId,
  });

  Future<ApiResponseModel> toggleSaveAuctionProduct({
    required AuctionSaveRequestModel saveProductRequest,
  });

  Future<ApiResponseModel> rollbackAuctionBid({required int auctionProductId, required double bidAmount, required String currencyCode});

  Future<ApiResponseModel> getAuctionSocialShareLink({required int productId});

  Future<ApiResponseModel> getAuctionInvoice(int auctionId);
}