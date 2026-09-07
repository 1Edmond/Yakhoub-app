import 'package:sixvalley_vendor_app/features/third_party_deliveryman/domain/models/courier_provider_model.dart';

class CourierEnabledProviderModel {
  String? id;
  String? label;
  List<String>? levels;
  Map<String, String>? levelLabels;
  List<CourierFieldModel>? addressFields;
  String? addressMode;
  List<String>? requiredFields;
  List<String>? optionalFields;
  List<CourierFieldOptionModel>? deliveryTypes;

  CourierEnabledProviderModel({
    this.id,
    this.label,
    this.levels,
    this.levelLabels,
    this.addressFields,
    this.addressMode,
    this.requiredFields,
    this.optionalFields,
    this.deliveryTypes,
  });

  factory CourierEnabledProviderModel.fromJson(Map<String, dynamic> json) {
    return CourierEnabledProviderModel(
      id: json['id'],
      label: json['label'],
      levels: (json['levels'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      levelLabels: _parseStringMap(json['level_labels']),
      addressFields: (json['address_fields'] as List<dynamic>?)
          ?.map((field) => CourierFieldModel.fromJson(field))
          .toList() ?? [],
      addressMode: json['address_mode'],
      requiredFields: (json['required_fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      optionalFields: (json['optional_fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      deliveryTypes: (json['delivery_types'] as List<dynamic>?)
          ?.map((type) => CourierFieldOptionModel.fromJson(type))
          .toList() ?? [],
    );
  }

  /// The backend serializes an empty PHP array as `[]` instead of `{}`,
  /// so `level_labels` can arrive as a List when empty.
  static Map<String, String> _parseStringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''));
    }
    return {};
  }
}
