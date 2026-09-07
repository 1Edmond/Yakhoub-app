class AiShoppingDigitalVariationModel {
  final String variantKey;
  final String label;
  final double price;
  final String? sku;

  const AiShoppingDigitalVariationModel({
    required this.variantKey,
    required this.label,
    required this.price,
    this.sku,
  });

  factory AiShoppingDigitalVariationModel.fromJson(Map<String, dynamic> json) {
    return AiShoppingDigitalVariationModel(
      variantKey: json['variant_key'] ?? '',
      label: json['label'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      sku: json['sku'],
    );
  }
}
