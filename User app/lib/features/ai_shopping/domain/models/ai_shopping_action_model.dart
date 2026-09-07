import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_preselect_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_shop_minimum_model.dart';

enum AiShoppingActionType {
  selectVariation,
  needsConfirmation,
  added,
  updated,
  minimumNotMet,
  checkout,
  unknown,
}

class AiShoppingActionModel {
  final AiShoppingActionType type;
  final int? productId;
  final bool? buyNow;
  final AiShoppingPreselectModel? preselect;
  final List<AiShoppingShopMinimumModel>? shops;
  final String? url;
  final String? name;
  final int? quantity;

  const AiShoppingActionModel({
    required this.type,
    this.productId,
    this.buyNow,
    this.preselect,
    this.shops,
    this.url,
    this.name,
    this.quantity,
  });

  factory AiShoppingActionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] ?? '';
    final AiShoppingActionType type = _parseType(typeStr);

    AiShoppingPreselectModel? preselect;
    if (json['preselect'] is Map) {
      preselect = AiShoppingPreselectModel.fromJson(
          Map<String, dynamic>.from(json['preselect']));
    }

    List<AiShoppingShopMinimumModel>? shops;
    if (json['shops'] is List) {
      shops = (json['shops'] as List<dynamic>)
          .map((e) => AiShoppingShopMinimumModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return AiShoppingActionModel(
      type: type,
      productId: json['product_id'],
      buyNow: json['buy_now'],
      preselect: preselect,
      shops: shops,
      url: json['url'],
      name: json['name'],
      quantity: json['quantity'],
    );
  }

  static AiShoppingActionType _parseType(String raw) {
    switch (raw) {
      case 'select_variation':
        return AiShoppingActionType.selectVariation;
      case 'needs_confirmation':
        return AiShoppingActionType.needsConfirmation;
      case 'added':
        return AiShoppingActionType.added;
      case 'updated':
        return AiShoppingActionType.updated;
      case 'minimum_not_met':
        return AiShoppingActionType.minimumNotMet;
      case 'checkout':
        return AiShoppingActionType.checkout;
      default:
        return AiShoppingActionType.unknown;
    }
  }
}
