import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

enum UserCreatedAuctionStatusEnum {
  all('all', 'all'),
  upcoming('upcoming', 'upcoming'),
  live('live', 'live'),
  readyToClaim('ready_to_claim', 'ready_to_claim'),
  purchaseComplete('purchase_complete', 'purchase_complete'),
  readyToDelivery('ready_to_delivery', 'ready_to_delivery'),
  onTheWay('on_the_way', 'on_the_way'),
  delivered('delivered', 'delivered'),
  unsold('unsold', 'unsold'),
  canceled('canceled', 'canceled');

  const UserCreatedAuctionStatusEnum(this.key, this._labelKey);

  final String key;
  final String _labelKey;

  String label(BuildContext context) => getTranslated(_labelKey, context) ?? key;
}