import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/repositories/participator/participation_auction_details_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class ParticipationAuctionDetailsRepository implements ParticipationAuctionDetailsRepositoryInterface {

  final DioClient? dioClient;

  ParticipationAuctionDetailsRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getAuctionProductOverview({
    required String slug,
    String? auctionStatus,
    int productStatus = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
       // if (auctionStatus != null) 'auction_status': auctionStatus,
        'similar_products': productStatus,
        'same_author_products': productStatus,
      };

      final response = await dioClient!.get(
        '${AppConstants.participationAuctionProductDetailsUri}$slug?guest_id=1',
        queryParameters: queryParams,
      );

      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getAuctionBidList({
    required int auctionProductId,
    bool isMyBid = false,
    int offset = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'offset': offset,
        'limit': limit,
        if (isMyBid) 'is_my_bid': 1,
      };
      final response = await dioClient!.get(
        '${AppConstants.auctionBidListUri}$auctionProductId', queryParameters: queryParams);
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