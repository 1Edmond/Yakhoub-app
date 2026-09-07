import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_bid_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_entry_fee_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_save_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/participator/auction_participation_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';


class AuctionParticipationRepository implements AuctionParticipationRepositoryInterface {
  final DioClient? dioClient;

  AuctionParticipationRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> payAuctionEntryFee({
    required AuctionEntryFeeRequestModel entryFeeRequest,
  }) async {
    try {
      final response = await dioClient!.post(AppConstants.auctionEntryFeeUri, data: entryFeeRequest.toJson());
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> placeAuctionBid({
    required AuctionBidRequestModel bidRequest,
  }) async {
    try {
      final response = await dioClient!.post(AppConstants.auctionPlaceBidUri, data: bidRequest.toJson());
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        return ApiResponseModel.withError(ApiErrorHandler.getMessage(e), responseValue: e.response);
      }
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> withdrawAuctionBid({
    required int auctionProductId,
  }) async {
    try {
      final response = await dioClient!.post(
        AppConstants.auctionWithdrawBidUri,
        data: {'auction_product_id': auctionProductId},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> rollbackAuctionBid({
    required int auctionProductId,
    required double bidAmount,
    required String currencyCode,
  }) async {
    try {
      final response = await dioClient!.post(
        AppConstants.auctionRollbackBidUri,
        data: {'auction_product_id': auctionProductId, 'bid_amount': bidAmount, 'currency_code': currencyCode},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> toggleSaveAuctionProduct({
    required AuctionSaveRequestModel saveProductRequest,
  }) async {
    try {
      final response = await dioClient!.post(
        '${AppConstants.baseUrl}${AppConstants.auctionSaveUri}',
        data: saveProductRequest.toJson(),
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getAuctionSocialShareLink({required int productId}) async {
    try{
      final response = await dioClient!.get('${AppConstants.baseUrl}${AppConstants.auctionSocialShareUri}$productId');
      return ApiResponseModel.withSuccess(response);
    }catch (e){
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getAuctionInvoice(int auctionId) async {
    try {
      final response = await dioClient!.get('${AppConstants.auctionGenerateInvoice}$auctionId');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) => throw UnimplementedError();

  @override
  Future delete(int id) => throw UnimplementedError();

  @override
  Future get(String id) => throw UnimplementedError();

  @override
  Future getList({int? offset = 1}) => throw UnimplementedError();

  @override
  Future update(Map<String, dynamic> body, int id) => throw UnimplementedError();
}