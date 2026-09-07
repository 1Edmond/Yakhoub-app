import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/domain/repository/auction_transaction_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:intl/intl.dart';

class AuctionTransactionRepository implements AuctionTransactionRepositoryInterface {
  final DioClient? dioClient;
  AuctionTransactionRepository({required this.dioClient});

  @override
  Future<ApiResponseModel> getAuctionTransactionList({
    int? searchAuctionId,
    int limit = 10,
    int offset = 1,
    String? filterBy,
    String? filterDurationType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
        if (searchAuctionId != null) 'search_auction_id': searchAuctionId,
        if (filterBy != null && filterBy != 'all') 'transaction_type[]': filterBy,
        if (filterDurationType != null && filterDurationType != 'all') 'filter_duration_type': filterDurationType,
        if (filterDurationType == 'custom' && startDate != null) 'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        if (filterDurationType == 'custom' && endDate != null) 'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      };
      final response = await dioClient!.get(AppConstants.auctionTransactionHistoryUri, queryParameters: queryParams);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponseModel> getSalesReport({required String dateType, String? startDate, String? endDate}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (dateType.isNotEmpty) queryParams['date_type'] = dateType;
      if (startDate != null) queryParams['from'] = startDate;
      if (endDate != null) queryParams['to'] = endDate;
      final response = await dioClient!.get(AppConstants.auctionSalesReportUri, queryParameters: queryParams);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future getList({int? offset = 1}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }
}
