import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/widgets/ai_shopping_product_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AiChatReceiverBubble extends StatelessWidget {
  final String? boldTitle;
  final String? body;
  final String? message;
  final List<AiShoppingProductModel>? products;
  final ValueChanged<AiShoppingProductModel>? onProductTap;

  const AiChatReceiverBubble({
    super.key,
    this.boldTitle,
    this.body,
    this.message,
    this.products,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasProducts = products != null && products!.isNotEmpty;
    final String? displayTitle = boldTitle;
    final String? displayBody = body ?? message;

    return Padding(
      padding: EdgeInsets.only(
        bottom: Dimensions.paddingSizeLarge,
        right: hasProducts ? 0 : 60,
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusSmall),
            topRight: Radius.circular(Dimensions.radiusLarge),
            bottomLeft: Radius.circular(Dimensions.radiusLarge),
            bottomRight: Radius.circular(Dimensions.radiusLarge),
          ),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayTitle != null && displayTitle.isNotEmpty)
              Text(
                displayTitle,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.5,
                ),
              ),
            if (displayBody != null && displayBody.isNotEmpty) ...[
              if (displayTitle != null && displayTitle.isNotEmpty)
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                displayBody,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.6,
                ),
              ),
            ],
            if (hasProducts) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              _AiProductsRow(products: products!, onProductTap: onProductTap),
            ],
          ],
        ),
      ),
    );
  }
}

class _AiProductsRow extends StatelessWidget {
  final List<AiShoppingProductModel> products;
  final ValueChanged<AiShoppingProductModel>? onProductTap;

  const _AiProductsRow({required this.products, this.onProductTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth / 2.5;
        return SizedBox(
          height: 185,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: products.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) => SizedBox(
              width: cardWidth,
              child: AiShoppingProductCardWidget(
                product: products[index],
                onTap: onProductTap != null
                    ? () => onProductTap!.call(products[index])
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
