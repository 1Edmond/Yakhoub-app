import 'dart:developer';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/repository/auction_dashboard_summary_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:provider/provider.dart';

class AuctionDashboardSummaryRepository implements AuctionDashboardSummaryRepositoryInterface {
  final DioClient? dioClient;
  AuctionDashboardSummaryRepository({required this.dioClient});

  void _setRequestHeaders(String? token) {
    final String? countryCode = dioClient!.countryCode;
    final String langValue =
        (countryCode == null || countryCode == 'US') ? 'en' : countryCode.toLowerCase();
    dioClient!.dio!.options.headers = {
      'Authorization': 'Bearer ${token ?? Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}',
      AppConstants.langKey: langValue,
    };
  }

  @override
  Future<ApiResponseModel> getAuctionDashboardSummary() async {
    final token = Provider.of<AuthController>(Get.context!, listen: false).getUserToken();
    _setRequestHeaders(token);
    try {
      final response = await dioClient!.get(AppConstants.auctionDashboardSummaryUri);
      log("DASHBOARD_RESPONSE: $response");
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
