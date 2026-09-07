import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AiShoppingProductCardWidget extends StatelessWidget {
  final AiShoppingProductModel product;
  final VoidCallback? onTap;

  const AiShoppingProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double rating = product.rating ?? 0;
    final int reviewCount = product.reviewsCount ?? 0;
    final double discount = product.discount ?? 0;
    final String productPrice = PriceConverter.convertPrice(
      context,
      product.unitPrice,
      discount: discount,
      discountType: 'percent',
    );
    final bool hasDiscount = product.hasDiscount;
    final String? originalPrice = hasDiscount
        ? PriceConverter.convertPrice(context, product.unitPrice)
        : null;
    final String displayPrice = hasDiscount
        ? (product.discountedPriceFormatted ?? productPrice)
        : (product.unitPriceFormatted ?? productPrice);
    final bool isOutOfStock =
        product.currentStock == 0 && product.productType == 'physical';

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
              child: Stack(
                children: [
                  CustomImageWidget(
                    width: double.infinity,
                    height: double.infinity,
                    image: product.thumbnailFullUrl ?? product.thumbnail ?? '',
                    fit: BoxFit.cover,
                  ),
                  if (isOutOfStock) ...[
                    Container(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withValues(alpha: 0.4),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.4),
                          child: Text(
                            getTranslated('out_of_stock', context) ?? '',
                            style: textBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
              if (rating > 0 && reviewCount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.secondary,
                      size: Dimensions.iconSizeExtraSmall,
                    ),
                    Text(
                      rating.toStringAsFixed(1),
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                    Expanded(
                      child: Text(
                        '($reviewCount ${getTranslated('review', context)!})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titilliumRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
              ],
              Text(
                displayPrice,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
              if (hasDiscount && originalPrice != null)
                Row(
                  children: [
                    Text(
                      originalPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.1),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall - 2),
                      child: Text(
                        '-${discount.toStringAsFixed(0)}%',
                        style: titilliumBold.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: Dimensions.fontSizeExtraSmall,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
