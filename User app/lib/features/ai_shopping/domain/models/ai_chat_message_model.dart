import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_action_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_preselect_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_shop_minimum_model.dart';

class AiChatMessage {
  final String id;
  final bool isUser;
  final String? message;
  final String? boldTitle;
  final String? body;
  final List<AiShoppingProductModel>? products;
  final AiShoppingProductModel? selectedProduct;
  final AiShoppingPreselectModel? preselect;
  final bool buyNow;
  final bool isLoading;
  final String? imageUrl;
  final String? checkoutUrl;
  final List<AiShoppingShopMinimumModel>? minimumNotMet;
  final List<AiShoppingActionModel>? actions;

  const AiChatMessage({
    required this.id,
    required this.isUser,
    this.message,
    this.boldTitle,
    this.body,
    this.products,
    this.selectedProduct,
    this.preselect,
    this.buyNow = false,
    this.isLoading = false,
    this.imageUrl,
    this.checkoutUrl,
    this.minimumNotMet,
    this.actions,
  });
}
