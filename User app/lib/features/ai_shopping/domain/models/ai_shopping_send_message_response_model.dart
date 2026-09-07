import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_action_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_product_model.dart';

class AiShoppingSendMessageResponse {
  final bool status;
  final String reply;
  final String intent;
  final List<AiShoppingProductModel> products;
  final List<AiShoppingActionModel> actions;

  const AiShoppingSendMessageResponse({
    required this.status,
    required this.reply,
    required this.intent,
    required this.products,
    required this.actions,
  });

  factory AiShoppingSendMessageResponse.fromJson(Map<String, dynamic> json) {
    return AiShoppingSendMessageResponse(
      status: json['status'] ?? false,
      reply: json['reply'] ?? '',
      intent: json['intent'] ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => AiShoppingProductModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => AiShoppingActionModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
