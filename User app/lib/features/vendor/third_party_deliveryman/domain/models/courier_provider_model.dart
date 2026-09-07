class CourierProviderModel {
  String? id;
  String? label;
  List<CourierFieldModel>? fields;
  bool? isEnabled;
  bool? isConfigured;
  Map<String, String>? credentials;
  String? environment;
  List<String>? environments;
  Map<String, String>? baseUrls;
  String? country;
  List<CourierCountryModel>? countries;
  String? webhookUrl;

  CourierProviderModel({
    this.id,
    this.label,
    this.fields,
    this.isEnabled,
    this.isConfigured,
    this.credentials,
    this.environment,
    this.environments,
    this.baseUrls,
    this.country,
    this.countries,
    this.webhookUrl,
  });

  factory CourierProviderModel.fromJson(Map<String, dynamic> json) {
    return CourierProviderModel(
      id: json['id'],
      label: json['label'],
      fields: (json['fields'] as List<dynamic>?)
          ?.map((field) => CourierFieldModel.fromJson(field))
          .toList() ?? [],
      isEnabled: json['is_enabled'] ?? false,
      isConfigured: json['is_configured'] ?? false,
      credentials: _parseStringMap(json['credentials']),
      environment: json['environment'],
      environments: (json['environments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      baseUrls: _parseStringMap(json['base_urls']),
      country: json['country'] ?? '',
      countries: (json['countries'] as List<dynamic>?)
          ?.map((country) => CourierCountryModel.fromJson(country))
          .toList() ?? [],
      webhookUrl: json['webhook_url'],
    );
  }

  /// The backend serializes an empty PHP array as `[]` instead of `{}`,
  /// so `credentials` / `base_urls` can arrive as a List when empty.
  static Map<String, String> _parseStringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''));
    }
    return {};
  }
}

class CourierFieldModel {
  String? key;
  String? label;
  String? type;
  bool? required;
  String? help;
  List<CourierFieldOptionModel>? options;
  bool? translatableOptions;

  CourierFieldModel({
    this.key,
    this.label,
    this.type,
    this.required,
    this.help,
    this.options,
    this.translatableOptions,
  });

  factory CourierFieldModel.fromJson(Map<String, dynamic> json) {
    return CourierFieldModel(
      key: json['key'],
      label: json['label'],
      type: json['type'],
      required: json['required'] ?? false,
      help: json['help'],
      options: (json['options'] as List<dynamic>?)
          ?.map((option) => CourierFieldOptionModel.fromJson(option))
          .toList() ?? [],
      translatableOptions: json['translatable_options'] ?? false,
    );
  }
}

class CourierFieldOptionModel {
  String? id;
  String? label;

  CourierFieldOptionModel({this.id, this.label});

  factory CourierFieldOptionModel.fromJson(Map<String, dynamic> json) {
    return CourierFieldOptionModel(id: json['id']?.toString(), label: json['label']);
  }
}

class CourierCountryModel {
  String? id;
  String? label;

  CourierCountryModel({this.id, this.label});

  factory CourierCountryModel.fromJson(Map<String, dynamic> json) {
    return CourierCountryModel(id: json['id']?.toString(), label: json['label']);
  }
}
