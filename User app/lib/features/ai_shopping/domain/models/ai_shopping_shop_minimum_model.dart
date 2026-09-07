class AiShoppingShopMinimumModel {
  final String shop;
  final String current;
  final String required;
  final String shortfall;

  const AiShoppingShopMinimumModel({
    required this.shop,
    required this.current,
    required this.required,
    required this.shortfall,
  });

  factory AiShoppingShopMinimumModel.fromJson(Map<String, dynamic> json) {
    return AiShoppingShopMinimumModel(
      shop: json['shop'] ?? '',
      current: json['current'] ?? '',
      required: json['required'] ?? '',
      shortfall: json['shortfall'] ?? '',
    );
  }
}
