class AiShoppingPreselectModel {
  final String? color;
  final Map<String, String>? choices;
  final int? qty;
  final String? variantKey;

  const AiShoppingPreselectModel({
    this.color,
    this.choices,
    this.qty,
    this.variantKey,
  });

  factory AiShoppingPreselectModel.fromJson(Map<String, dynamic> json) {
    Map<String, String>? choices;
    final raw = json['choices'];
    if (raw is Map) {
      choices = raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return AiShoppingPreselectModel(
      color: json['color'],
      choices: choices,
      qty: json['qty'],
      variantKey: json['variant_key'],
    );
  }
}
