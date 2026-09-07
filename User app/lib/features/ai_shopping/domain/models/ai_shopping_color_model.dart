class AiShoppingColorModel {
  final String? name;
  final String? code;

  const AiShoppingColorModel({this.name, this.code});

  factory AiShoppingColorModel.fromJson(Map<String, dynamic> json) {
    return AiShoppingColorModel(
      name: json['name'],
      code: json['code'],
    );
  }
}
