import 'package:sixvalley_vendor_app/features/third_party_deliveryman/domain/repositories/third_party_deliveryman_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/domain/services/third_party_deliveryman_service_interface.dart';

class ThirdPartyDeliverymanService implements ThirdPartyDeliverymanServiceInterface {
  final ThirdPartyDeliverymanRepositoryInterface repositoryInterface;
  ThirdPartyDeliverymanService({required this.repositoryInterface});

  @override
  Future getCourierConfig() async {
    return await repositoryInterface.getCourierConfig();
  }

  @override
  Future saveCourierConfig(Map<String, dynamic> body) async {
    return await repositoryInterface.saveCourierConfig(body);
  }

  @override
  Future getEnabledProviders() async {
    return await repositoryInterface.getEnabledProviders();
  }

  @override
  Future sendToCourier(Map<String, dynamic> body) async {
    return await repositoryInterface.sendToCourier(body);
  }

  @override
  Future reviseDeliveryDetails(Map<String, dynamic> body) async {
    return await repositoryInterface.reviseDeliveryDetails(body);
  }

  @override
  Future estimateDeliveryCharge(Map<String, dynamic> body) async {
    return await repositoryInterface.estimateDeliveryCharge(body);
  }

  @override
  Future getTrackingHistory(String consignmentId) async {
    return await repositoryInterface.getTrackingHistory(consignmentId);
  }

  @override
  Future getCourierLocationStores(String provider) async {
    return await repositoryInterface.getCourierLocationStores(provider);
  }

  @override
  Future getCourierLocationCities(String provider) async {
    return await repositoryInterface.getCourierLocationCities(provider);
  }

  @override
  Future getCourierLocationZones(String provider, String cityId) async {
    return await repositoryInterface.getCourierLocationZones(provider, cityId);
  }

  @override
  Future getCourierLocationAreas(String provider, String zoneId) async {
    return await repositoryInterface.getCourierLocationAreas(provider, zoneId);
  }
}
