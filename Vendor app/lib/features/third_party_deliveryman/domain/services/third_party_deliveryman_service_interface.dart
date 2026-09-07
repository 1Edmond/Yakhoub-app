abstract class ThirdPartyDeliverymanServiceInterface {
  Future<dynamic> getCourierConfig();
  Future<dynamic> saveCourierConfig(Map<String, dynamic> body);
  Future<dynamic> getEnabledProviders();
  Future<dynamic> sendToCourier(Map<String, dynamic> body);
  Future<dynamic> reviseDeliveryDetails(Map<String, dynamic> body);
  Future<dynamic> estimateDeliveryCharge(Map<String, dynamic> body);
  Future<dynamic> getTrackingHistory(String consignmentId);
  Future<dynamic> getCourierLocationStores(String provider);
  Future<dynamic> getCourierLocationCities(String provider);
  Future<dynamic> getCourierLocationZones(String provider, String cityId);
  Future<dynamic> getCourierLocationAreas(String provider, String zoneId);
}
