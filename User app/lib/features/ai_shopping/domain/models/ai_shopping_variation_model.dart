class AiShoppingVariationModel {
  final String type;
  final double price;
  final String? sku;
  final int? qty;

  const AiShoppingVariationModel({
    required this.type,
    required this.price,
    this.sku,
    this.qty,
  });

  factory AiShoppingVariationModel.fromJson(Map<String, dynamic> json) {
    return AiShoppingVariationModel(
      type: json['type'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      sku: json['sku'],
      qty: json['qty'],
    );
  }
}
