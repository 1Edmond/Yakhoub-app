import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_choice_option_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_color_image_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_color_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_digital_variation_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_variation_model.dart';

class AiShoppingProductModel {
  final int id;
  final String name;
  final String? slug;
  final double unitPrice;
  final String? unitPriceFormatted;
  final double? discount;
  final String? discountType;
  final String? discountFormatted;
  final double? discountedPrice;
  final String? discountedPriceFormatted;
  final double? rating;
  final int? reviewsCount;
  final String? thumbnail;
  final String? thumbnailFullUrl;
  final int? currentStock;
  final String? productType;
  final List<AiShoppingColorModel> colors;
  final List<AiShoppingColorImageModel> colorImages;
  final List<AiShoppingChoiceOptionModel> choiceOptions;
  final List<AiShoppingVariationModel> physicalVariations;
  final List<AiShoppingDigitalVariationModel> digitalVariations;
  final Map<String, List<String>>? digitalProductExtensions;
  final int? minimumOrderQty;

  const AiShoppingProductModel({
    required this.id,
    required this.name,
    this.slug,
    required this.unitPrice,
    this.unitPriceFormatted,
    this.discount,
    this.discountType,
    this.discountFormatted,
    this.discountedPrice,
    this.discountedPriceFormatted,
    this.rating,
    this.reviewsCount,
    this.thumbnail,
    this.thumbnailFullUrl,
    this.currentStock,
    this.productType,
    this.colors = const [],
    this.colorImages = const [],
    this.choiceOptions = const [],
    this.physicalVariations = const [],
    this.digitalVariations = const [],
    this.digitalProductExtensions,
    this.minimumOrderQty,
  });

  bool get isDigital => productType == 'digital' || digitalVariations.isNotEmpty;
  bool get hasColors => colors.isNotEmpty;
  bool get hasChoiceOptions => choiceOptions.isNotEmpty;
  bool get hasPhysicalVariations => physicalVariations.isNotEmpty;
  bool get hasDiscount => (discount ?? 0) > 0;

  factory AiShoppingProductModel.fromJson(Map<String, dynamic> json) {
    return AiShoppingProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      unitPriceFormatted: json['unit_price_formatted'],
      discount: (json['discount'] as num?)?.toDouble(),
      discountType: json['discount_type'],
      discountFormatted: json['discount_formatted'],
      discountedPrice: (json['discounted_price'] as num?)?.toDouble(),
      discountedPriceFormatted: json['discounted_price_formatted'],
      rating: (json['rating'] as num?)?.toDouble() ??
          (json['avg_rating'] as num?)?.toDouble(),
      reviewsCount: json['reviews_count'] ?? json['rating_count'],
      thumbnail: json['thumbnail'],
      thumbnailFullUrl: json['thumbnail_full_url'],
      currentStock: json['current_stock'],
      productType: json['product_type'],
      colors: (json['colors'] as List<dynamic>?)
              ?.map((e) => AiShoppingColorModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      colorImages: (json['color_images'] as List<dynamic>?)
              ?.map((e) => AiShoppingColorImageModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      choiceOptions: (json['choice_options'] as List<dynamic>?)
              ?.map((e) => AiShoppingChoiceOptionModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      physicalVariations: (json['variation'] as List<dynamic>?)
              ?.map((e) => AiShoppingVariationModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      digitalVariations: () {
        // Prefer explicit pre-built list (AI-specific format with labels)
        final explicit = (json['digital_variations'] as List<dynamic>?)
            ?.map((e) => AiShoppingDigitalVariationModel.fromJson(
                  Map<String, dynamic>.from(e)))
            .toList();
        if (explicit != null && explicit.isNotEmpty) return explicit;

        // Derive from digital_product_extensions + digital_variation price table
        // (same fields the regular product API returns)
        final extMap = json['digital_product_extensions'];
        if (extMap == null || extMap is! Map) {
          return <AiShoppingDigitalVariationModel>[];
        }
        final priceList =
            (json['digital_variation'] as List<dynamic>?) ?? [];
        final basePrice =
            (json['unit_price'] as num?)?.toDouble() ?? 0.0;

        double priceFor(String key) {
          for (final item in priceList) {
            if (item['variant_key'] == key) {
              return (item['price'] as num?)?.toDouble() ?? basePrice;
            }
          }
          return basePrice;
        }

        final result = <AiShoppingDigitalVariationModel>[];
        (extMap as Map<String, dynamic>).forEach((type, exts) {
          if (exts is List) {
            for (final ext in exts) {
              final key = '$type-$ext';
              final typeCap = type.isNotEmpty
                  ? '${type[0].toUpperCase()}${type.substring(1)}'
                  : type;
              result.add(AiShoppingDigitalVariationModel(
                variantKey: key,
                label: '$typeCap - $ext',
                price: priceFor(key),
              ));
            }
          }
        });
        return result;
      }(),
      digitalProductExtensions: () {
        final ext = json['digital_product_extensions'];
        if (ext == null || ext is List) return null;
        return (ext as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>()),
        );
      }(),
      minimumOrderQty: json['minimum_order_qty'],
    );
  }
}
