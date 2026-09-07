import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/models/courier_enabled_provider_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/models/courier_location_option_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/models/courier_provider_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/models/courier_tracking_event_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/services/third_party_deliveryman_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/helper/api_checker.dart';

class ThirdPartyDeliverymanController extends ChangeNotifier {
  final ThirdPartyDeliverymanServiceInterface serviceInterface;
  ThirdPartyDeliverymanController({required this.serviceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  List<CourierProviderModel> _providers = [];
  List<CourierProviderModel> get providers => _providers;

  bool get hasEnabledProvider => _providers.any((provider) => provider.isEnabled == true);

  Future<void> getCourierConfig(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final ApiResponse response = await serviceInterface.getCourierConfig();
    if (response.response != null && response.response!.statusCode == 200) {
      final List<dynamic> providersJson = response.response!.data['providers'] ?? [];
      _providers = providersJson.map((provider) => CourierProviderModel.fromJson(provider)).toList();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveCourierConfig(BuildContext context, Map<String, dynamic> body) async {
    _isSaving = true;
    notifyListeners();

    final ApiResponse response = await serviceInterface.saveCourierConfig(body);
    bool isSuccess = false;
    if (response.response != null && response.response!.statusCode == 200) {
      isSuccess = true;
    } else {
      ApiChecker.checkApi(response);
    }

    _isSaving = false;
    notifyListeners();
    return isSuccess;
  }

  Future<bool> toggleProvider(BuildContext context, CourierProviderModel provider, bool isEnabled) async {
    final bool previousValue = provider.isEnabled ?? false;
    provider.isEnabled = isEnabled;
    notifyListeners();

    final bool isSuccess = await saveCourierConfig(context, {
      'provider': provider.id,
      'is_enabled': isEnabled,
    });

    if (!isSuccess) {
      provider.isEnabled = previousValue;
      notifyListeners();
    }

    return isSuccess;
  }

  bool _isLoadingProviders = false;
  bool get isLoadingProviders => _isLoadingProviders;

  List<CourierEnabledProviderModel> _enabledProviders = [];
  List<CourierEnabledProviderModel> get enabledProviders => _enabledProviders;

  String? _selectedProviderId;
  String? get selectedProviderId => _selectedProviderId;

  void selectProvider(String? providerId) {
    _selectedProviderId = providerId;
    notifyListeners();
  }

  Future<void> getEnabledProviders(BuildContext context) async {
    _isLoadingProviders = true;
    notifyListeners();

    final ApiResponse response = await serviceInterface.getEnabledProviders();
    if (response.response != null && response.response!.statusCode == 200) {
      final List<dynamic> providersJson = response.response!.data['providers'] ?? [];
      _enabledProviders = providersJson.map((provider) => CourierEnabledProviderModel.fromJson(provider)).toList();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoadingProviders = false;
    notifyListeners();
  }

  bool _isDispatching = false;
  bool get isDispatching => _isDispatching;

  Future<({bool success, String message})> sendToCourier(BuildContext context, Map<String, dynamic> body) async {
    _isDispatching = true;
    notifyListeners();

    final ApiResponse response = await serviceInterface.sendToCourier(body);
    bool isSuccess = false;
    String message = '';

    if (response.response != null && response.response!.statusCode == 200) {
      final data = response.response!.data;
      isSuccess = data['ok'] == true;
      message = data['message']?.toString() ?? '';
    } else {
      ApiChecker.checkApi(response);
    }

    _isDispatching = false;
    notifyListeners();
    return (success: isSuccess, message: message);
  }

  bool _isRevising = false;
  bool get isRevising => _isRevising;

  Future<({bool success, String message})> reviseDeliveryDetails(BuildContext context, Map<String, dynamic> body) async {
    _isRevising = true;
    notifyListeners();

    final ApiResponse response = await serviceInterface.reviseDeliveryDetails(body);
    bool isSuccess = false;
    String message = '';

    if (response.response != null && response.response!.statusCode == 200) {
      final data = response.response!.data;
      isSuccess = data['ok'] == true;
      message = data['message']?.toString() ?? '';
    } else {
      ApiChecker.checkApi(response);
    }

    _isRevising = false;
    notifyListeners();
    return (success: isSuccess, message: message);
  }

  bool _isEstimating = false;
  bool get isEstimating => _isEstimating;

  Future<({bool ok, bool supported, double? total, String? currency, String? message})> estimateDeliveryCharge(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    _isEstimating = true;
    notifyListeners();

    final ApiResponse response = await serviceInterface.estimateDeliveryCharge(body);
    bool ok = false;
    bool supported = false;
    double? total;
    String? currency;
    String? message;

    if (response.response != null && response.response!.statusCode == 200) {
      try {
        final data = response.response!.data;
        ok = data['ok'] == true;
        supported = data['supported'] == true;
        total = data['total'] is num ? (data['total'] as num).toDouble() : double.tryParse(data['total']?.toString() ?? '');
        currency = data['currency']?.toString();
        message = data['message']?.toString();
      } catch (_) {
        ok = false;
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isEstimating = false;
    notifyListeners();
    return (ok: ok, supported: supported, total: total, currency: currency, message: message);
  }

  bool _isLoadingTrackingHistory = false;
  bool get isLoadingTrackingHistory => _isLoadingTrackingHistory;

  Future<({bool ok, List<CourierTrackingEventModel> events, String? message})> getTrackingHistory(
    BuildContext context,
    String consignmentId,
  ) async {
    _isLoadingTrackingHistory = true;
    notifyListeners();

    final ApiResponse response = await serviceInterface.getTrackingHistory(consignmentId);
    bool ok = false;
    List<CourierTrackingEventModel> events = [];
    String? message;

    if (response.response != null && response.response!.statusCode == 200) {
      try {
        final data = response.response!.data;
        ok = data['ok'] == true;
        final List<dynamic> eventsJson = data['events'] ?? [];
        events = eventsJson.map((event) => CourierTrackingEventModel.fromJson(event)).toList();
        message = data['message']?.toString();
      } catch (_) {
        ok = false;
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoadingTrackingHistory = false;
    notifyListeners();
    return (ok: ok, events: events, message: message);
  }

  ({bool supported, List<CourierLocationOptionModel> options, String? message}) _parseLocationResponse(ApiResponse response) {
    bool supported = false;
    List<CourierLocationOptionModel> options = [];
    String? message;

    if (response.response != null && response.response!.statusCode == 200) {
      try {
        final data = response.response!.data;
        supported = data['supported'] == true;
        final List<dynamic> optionsJson = data['options'] ?? [];
        options = optionsJson.map((option) => CourierLocationOptionModel.fromJson(option)).toList();
        message = data['message']?.toString();
      } catch (_) {
        supported = false;
      }
    } else {
      ApiChecker.checkApi(response);
    }

    return (supported: supported, options: options, message: message);
  }

  Future<({bool supported, List<CourierLocationOptionModel> options, String? message})> getPickupStores(
    BuildContext context,
    String provider,
  ) async {
    return _parseLocationResponse(await serviceInterface.getCourierLocationStores(provider));
  }

  Future<({bool supported, List<CourierLocationOptionModel> options, String? message})> getCities(
    BuildContext context,
    String provider,
  ) async {
    return _parseLocationResponse(await serviceInterface.getCourierLocationCities(provider));
  }

  Future<({bool supported, List<CourierLocationOptionModel> options, String? message})> getZones(
    BuildContext context,
    String provider,
    String cityId,
  ) async {
    return _parseLocationResponse(await serviceInterface.getCourierLocationZones(provider, cityId));
  }

  Future<({bool supported, List<CourierLocationOptionModel> options, String? message})> getAreas(
    BuildContext context,
    String provider,
    String zoneId,
  ) async {
    return _parseLocationResponse(await serviceInterface.getCourierLocationAreas(provider, zoneId));
  }
}
