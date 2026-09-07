import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_product_model.dart';

class AiShoppingHistoryMessage {
  final int id;
  final String role;
  final String? content;
  final String? imageUrl;
  final List<AiShoppingProductModel> products;
  final String createdAt;

  const AiShoppingHistoryMessage({
    required this.id,
    required this.role,
    this.content,
    this.imageUrl,
    this.products = const [],
    required this.createdAt,
  });

  factory AiShoppingHistoryMessage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return AiShoppingHistoryMessage(
      id: json['id'] ?? 0,
      role: json['role'] ?? 'user',
      content: json['content'],
      imageUrl: meta['image_url'] as String?,
      products: (meta['products'] as List<dynamic>?)
              ?.map((e) => AiShoppingProductModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
    );
  }
}
