import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_bid_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_entry_fee_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_save_request_model.dart';

abstract class AuctionParticipationServiceInterface {

  Future<dynamic> payAuctionEntryFee({
    required AuctionEntryFeeRequestModel entryFeeRequest,
  });

  Future<dynamic> placeAuctionBid({
    required AuctionBidRequestModel bidRequest,
  });

  Future<dynamic> withdrawAuctionBid({
    required int auctionProductId,
  });

  Future<dynamic> toggleSaveAuctionProduct({
    required AuctionSaveRequestModel saveProductRequest,
  });

  Future<dynamic> rollbackAuctionBid({required int auctionProductId, required double bidAmount, required String currencyCode});

  Future<dynamic> getAuctionSocialShareLink({required int productId});

  Future<dynamic> getAuctionInvoice(int auctionId);
}