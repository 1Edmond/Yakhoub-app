import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/enum/creator/auction_delivery_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/creator/creator_auction_details_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class CreatorAuctionDetailsRepository implements CreatorAuctionDetailsRepositoryInterface {
  final DioClient? dioClient;

  CreatorAuctionDetailsRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getAuctionDetails(String slug) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.creatorAuctionProductDetailsUri}/$slug',
        queryParameters: {'guest_id': '1'},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getAuctionBidList({
    required int auctionProductId,
    int offset = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'offset': offset,
        'limit': limit,
      };
      final response = await dioClient!.get('${AppConstants.auctionCreatorBidListUri}$auctionProductId', queryParameters: queryParams);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> uploadTrackingUrl(int auctionProductId, String trackingUrl) async {
    try {
      final response = await dioClient!.put('${AppConstants.auctionUploadTrackingUri}$auctionProductId',
        data: {
          'tracking_url': trackingUrl,
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> updateDeliveryStatus(int auctionProductId, AuctionDeliveryStatus status) async {
    try {
      final response = await dioClient!.put(
        '${AppConstants.auctionDeliveryStatusUri}$auctionProductId',
        data: {'delivery_status': status.value},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override Future add(value) => throw UnimplementedError();
  @override Future delete(int id) => throw UnimplementedError();
  @override Future get(String id) => throw UnimplementedError();
  @override Future getList({int? offset = 1}) => throw UnimplementedError();
  @override Future update(Map<String, dynamic> body, int id) => throw UnimplementedError();
}