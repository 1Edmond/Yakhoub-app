import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/repository/user_created_auction_list_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:provider/provider.dart';

class UserCreatedAuctionListRepository implements UserCreatedAuctionListRepositoryInterface {
  final DioClient? dioClient;
  UserCreatedAuctionListRepository({required this.dioClient});

  void _setRequestHeaders() {
    dioClient!.dio!.options.headers = {
      'Authorization': 'Bearer ${Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}',
    };
  }

  @override
  Future<ApiResponseModel> getMyAuctionList({
    required int offset,
    required String auctionStatus,
    int limit = 10,
    bool includeCounts = false,
  }) async {
    try {
      _setRequestHeaders();
      final StringBuffer url = StringBuffer(
        '${AppConstants.userCreatedAuctionList}?limit=$limit&offset=$offset&auction_status=$auctionStatus&approval_status=approved',
      );
      if (includeCounts) url.write('&include_counts=1');
      final response = await dioClient!.get(url.toString());
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override Future add(value)  => throw UnimplementedError();
  @override Future delete(int id) => throw UnimplementedError();
  @override Future get(String id) => throw UnimplementedError();
  @override Future getList({int? offset = 1})  => throw UnimplementedError();
  @override Future update(Map<String, dynamic> body, int id) => throw UnimplementedError();
}