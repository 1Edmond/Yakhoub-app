import 'dart:io';
import 'package:flutter_sixvalley_ecommerce/features/vendor/data/model/response/base/api_response.dart';

abstract class ProductDetailsRepositoryInterface {
  Future<ApiResponse> getProductDetails(int? productId);
  Future<ApiResponse> productStatusOnOff(int? productId, int status);
  Future<HttpClientResponse> previewDownload(String url);
}
