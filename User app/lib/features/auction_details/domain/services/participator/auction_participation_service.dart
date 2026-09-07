import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_bid_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_entry_fee_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_save_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/participator/auction_participation_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/participator/auction_participation_service_interface.dart';

class AuctionParticipationService implements AuctionParticipationServiceInterface {
  final AuctionParticipationRepositoryInterface auctionRepositoryInterface;

  AuctionParticipationService({required this.auctionRepositoryInterface});

  @override
  Future payAuctionEntryFee({
    required AuctionEntryFeeRequestModel entryFeeRequest,
  }) async {
    return await auctionRepositoryInterface.payAuctionEntryFee(
      entryFeeRequest: entryFeeRequest,
    );
  }

  @override
  Future placeAuctionBid({
    required AuctionBidRequestModel bidRequest,
  }) async {
    return await auctionRepositoryInterface.placeAuctionBid(
      bidRequest: bidRequest,
    );
  }

  @override
  Future withdrawAuctionBid({
    required int auctionProductId,
  }) async {
    return await auctionRepositoryInterface.withdrawAuctionBid(
      auctionProductId: auctionProductId,
    );
  }

  @override
  Future toggleSaveAuctionProduct({
    required AuctionSaveRequestModel saveProductRequest,
  }) async {
    return await auctionRepositoryInterface.toggleSaveAuctionProduct(
      saveProductRequest: saveProductRequest,
    );
  }

  @override
  Future rollbackAuctionBid({
    required int auctionProductId,
    required double bidAmount,
    required String currencyCode,
  }) async {
    return await auctionRepositoryInterface.rollbackAuctionBid(auctionProductId: auctionProductId, bidAmount: bidAmount, currencyCode: currencyCode);
  }

  @override
  Future getAuctionSocialShareLink({required int productId}) async {
    return await auctionRepositoryInterface.getAuctionSocialShareLink(productId: productId);
  }

  @override
  Future getAuctionInvoice(int auctionId) async {
    return await auctionRepositoryInterface.getAuctionInvoice(auctionId);
  }
}