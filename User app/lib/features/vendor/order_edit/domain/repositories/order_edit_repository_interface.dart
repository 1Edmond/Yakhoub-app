import 'package:flutter_sixvalley_ecommerce/features/vendor/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/interface/repository_interface.dart';

abstract class OrderEditRepositoryInterface implements RepositoryInterface {
  Future<ApiResponse> getSellerProductList({
    required String sellerId,
    required int offset,
    required String languageCode,
    required String search,
    required String orderId,
  });


  Future<ApiResponse> editOrderSubmit(Map<String, dynamic> data);

  Future<ApiResponse> switchToCod(int orderId);

  Future<ApiResponse> editOrderValidation(Map<String, dynamic> data);


}
