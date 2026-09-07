import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/localization/language_constrants.dart';

extension PaymentMethodLabelExtension on String? {
  String toPaymentMethodLabel(BuildContext context) {
    return getTranslated(this ?? '', context) ?? this ?? '';
  }
}
