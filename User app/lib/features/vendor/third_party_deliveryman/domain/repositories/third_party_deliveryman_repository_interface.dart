import 'package:flutter_sixvalley_ecommerce/features/vendor/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/interface/repository_interface.dart';

abstract class ThirdPartyDeliverymanRepositoryInterface implements RepositoryInterface {
  Future<ApiResponse> getCourierConfig();
  Future<ApiResponse> saveCourierConfig(Map<String, dynamic> body);
  Future<ApiResponse> getEnabledProviders();
  Future<ApiResponse> sendToCourier(Map<String, dynamic> body);
  Future<ApiResponse> reviseDeliveryDetails(Map<String, dynamic> body);
  Future<ApiResponse> estimateDeliveryCharge(Map<String, dynamic> body);
  Future<ApiResponse> getTrackingHistory(String consignmentId);
  Future<ApiResponse> getCourierLocationStores(String provider);
  Future<ApiResponse> getCourierLocationCities(String provider);
  Future<ApiResponse> getCourierLocationZones(String provider, String cityId);
  Future<ApiResponse> getCourierLocationAreas(String provider, String zoneId);
}
