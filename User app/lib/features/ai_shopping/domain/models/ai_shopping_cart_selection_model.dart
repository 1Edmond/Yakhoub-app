class AiShoppingCartSelection {
  final int productId;
  final String? color;
  final Map<String, String>? choices;
  final int? qty;
  final String? variantKey;

  const AiShoppingCartSelection({
    required this.productId,
    this.color,
    this.choices,
    this.qty,
    this.variantKey,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'product_id': productId};
    if (color != null) data['color'] = color;
    if (choices != null && choices!.isNotEmpty) data['choices'] = choices;
    if (qty != null) data['qty'] = qty;
    if (variantKey != null) data['variant_key'] = variantKey;
    return data;
  }
}
