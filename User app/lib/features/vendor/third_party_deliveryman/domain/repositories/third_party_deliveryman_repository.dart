import 'package:flutter_sixvalley_ecommerce/features/vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/repositories/third_party_deliveryman_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/app_constants.dart';

class ThirdPartyDeliverymanRepository implements ThirdPartyDeliverymanRepositoryInterface {
  final DioClient? dioClient;
  ThirdPartyDeliverymanRepository({required this.dioClient});

  @override
  Future<ApiResponse> getCourierConfig() async {
    try {
      final response = await dioClient!.get(AppConstants.courierConfigUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> saveCourierConfig(Map<String, dynamic> body) async {
    try {
      final response = await dioClient!.put(AppConstants.courierConfigUri, data: body);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getEnabledProviders() async {
    try {
      final response = await dioClient!.get(AppConstants.courierProvidersUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> sendToCourier(Map<String, dynamic> body) async {
    try {
      final response = await dioClient!.post(AppConstants.courierDispatchUri, data: body);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> reviseDeliveryDetails(Map<String, dynamic> body) async {
    try {
      final response = await dioClient!.post(AppConstants.courierReviseUri, data: body);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> estimateDeliveryCharge(Map<String, dynamic> body) async {
    try {
      final response = await dioClient!.post(AppConstants.courierEstimateUri, data: body);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getTrackingHistory(String consignmentId) async {
    try {
      final response = await dioClient!.get('${AppConstants.courierTrackUri}$consignmentId');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getCourierLocationStores(String provider) async {
    try {
      final response = await dioClient!.get(AppConstants.courierLocationStoresUri, queryParameters: {'provider': provider});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getCourierLocationCities(String provider) async {
    try {
      final response = await dioClient!.get(AppConstants.courierLocationCitiesUri, queryParameters: {'provider': provider});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getCourierLocationZones(String provider, String cityId) async {
    try {
      final response = await dioClient!.get('${AppConstants.courierLocationZonesUri}$cityId', queryParameters: {'provider': provider});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getCourierLocationAreas(String provider, String zoneId) async {
    try {
      final response = await dioClient!.get('${AppConstants.courierLocationAreasUri}$zoneId', queryParameters: {'provider': provider});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
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
