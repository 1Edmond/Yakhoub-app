import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

enum UserCreatedAuctionPurchaseEnum {
  live('live'),
  upcoming('upcoming'),
  readyToClaim('ready_to_claim'),
  purchaseComplete('purchase_complete'),
  readyToDelivery('ready_to_delivery'),
  onTheWay('on_the_way'),
  delivered('delivered'),
  unsold('unsold'),
  canceled('canceled'),
  recreated('recreated');

  const UserCreatedAuctionPurchaseEnum(this.key);

  final String key;

  String label(BuildContext context) => getTranslated(key, context) ?? key;

  Color badgeColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (this) {
      case live:             return cs.error;
      case upcoming:         return cs.secondary;
      case readyToClaim:     return cs.tertiary;
      case purchaseComplete: return cs.onTertiaryContainer;
      case readyToDelivery:  return cs.onTertiaryContainer.withValues(alpha: 0.7);
      case onTheWay:         return cs.secondary.withValues(alpha: 0.75);
      case delivered:        return cs.onTertiaryContainer.withValues(alpha: 0.85);
      case unsold:           return Theme.of(context).hintColor;
      case canceled:         return cs.error.withValues(alpha: 0.55);
      case recreated:        return cs.primary.withValues(alpha: 0.7);
    }
  }

  static UserCreatedAuctionPurchaseEnum fromApi(String? status, String? deliveryStatus, {bool isRelaunched = false}) {
    if (isRelaunched) return recreated;
    if (deliveryStatus != null) {
      return values.firstWhere((e) => e.key == deliveryStatus, orElse: () => upcoming);
    }
    return values.firstWhere((e) => e.key == status, orElse: () => upcoming);
  }
}
