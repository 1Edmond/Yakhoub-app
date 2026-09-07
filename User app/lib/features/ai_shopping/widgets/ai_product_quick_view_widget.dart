import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/controllers/ai_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_chat_message_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_digital_variation_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_preselect_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_variation_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/app_localization.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AiProductQuickView extends StatefulWidget {
  final AiShoppingProductModel product;
  final AiShoppingPreselectModel? preselect;
  final bool buyNow;
  final VoidCallback? onDismiss;
  final String messageId;

  const AiProductQuickView({
    super.key,
    required this.product,
    required this.messageId,
    this.preselect,
    this.buyNow = false,
    this.onDismiss,
  });

  @override
  State<AiProductQuickView> createState() => _AiProductQuickViewState();
}

class _AiProductQuickViewState extends State<AiProductQuickView> {
  int _selectedColorIndex = -1;
  late List<int> _selectedVariationIndices;
  int _selectedDigitalIndex = -1;
  int _quantity = 1;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _selectedColorIndex = widget.product.hasColors ? 0 : -1;
    _selectedVariationIndices =
        List.filled(widget.product.choiceOptions.length, 0);
    _applyPreselect(widget.preselect);
  }

  @override
  void didUpdateWidget(AiProductQuickView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _selectedColorIndex = widget.product.hasColors ? 0 : -1;
      _selectedVariationIndices =
          List.filled(widget.product.choiceOptions.length, 0);
      _selectedDigitalIndex = -1;
      _quantity = 1;
      _applyPreselect(widget.preselect);
    }
  }

  void _applyPreselect(AiShoppingPreselectModel? p) {
    if (p == null) return;
    if (p.qty != null) _quantity = p.qty!;

    if (p.variantKey != null && widget.product.isDigital) {
      final idx = widget.product.digitalVariations
          .indexWhere((v) => v.variantKey == p.variantKey);
      if (idx >= 0) _selectedDigitalIndex = idx;
    }

    if (p.color != null && widget.product.hasColors) {
      final idx =
          widget.product.colors.indexWhere((c) => c.code == p.color);
      if (idx >= 0) _selectedColorIndex = idx;
    }

    if (p.choices != null && widget.product.hasChoiceOptions) {
      for (int i = 0; i < widget.product.choiceOptions.length; i++) {
        final option = widget.product.choiceOptions[i];
        final chosen = p.choices![option.name ?? option.title ?? ''];
        if (chosen != null) {
          final j = option.options.indexOf(chosen);
          if (j >= 0) _selectedVariationIndices[i] = j;
        }
      }
    }
  }

  // Build the variation type key e.g. "RoyalBlue-Small-Cotton"
  String _buildVariationType() {
    final parts = <String>[];
    if (_selectedColorIndex >= 0 && widget.product.hasColors) {
      parts.add(widget.product.colors[_selectedColorIndex].name ?? '');
    }
    for (int i = 0; i < widget.product.choiceOptions.length; i++) {
      final option = widget.product.choiceOptions[i];
      if (option.options.isNotEmpty) {
        parts.add(option.options[_selectedVariationIndices[i]]);
      }
    }
    return parts.join('-').replaceAll(' ', '');
  }

  AiShoppingVariationModel? _matchedPhysicalVariation() {
    if (!widget.product.hasPhysicalVariations) return null;
    final type = _buildVariationType();
    try {
      return widget.product.physicalVariations.firstWhere(
        (v) => v.type.replaceAll(' ', '') == type,
      );
    } catch (_) {
      return null;
    }
  }

  // Base price per unit (before discount)
  double get _basePrice {
    if (widget.product.isDigital &&
        _selectedDigitalIndex >= 0 &&
        _selectedDigitalIndex < widget.product.digitalVariations.length) {
      return widget.product.digitalVariations[_selectedDigitalIndex].price;
    }
    final matched = _matchedPhysicalVariation();
    if (matched != null) return matched.price;
    return widget.product.discountedPrice ?? widget.product.unitPrice;
  }

  // Discounted price per unit
  double _discountedUnitPrice(BuildContext context) {
    if (widget.product.isDigital) return _basePrice;
    return PriceConverter.convertWithDiscount(
          context,
          _basePrice,
          widget.product.discount,
          widget.product.discountType,
        ) ??
        _basePrice;
  }

  int _effectiveStockFor(AiShoppingVariationModel? matched) {
    return matched?.qty ?? widget.product.currentStock ?? 0;
  }

  bool get _isSelectedVariationOutOfStock {
    final product = widget.product;
    if (product.isDigital) return false;
    if (product.hasPhysicalVariations && _buildVariationType().isEmpty) {
      return false;
    }
    final matched = _matchedPhysicalVariation();
    final int effectiveStock = _effectiveStockFor(matched);
    if (matched != null && effectiveStock < (product.minimumOrderQty ?? 1)) {
      return true;
    }
    return effectiveStock <= 0;
  }

  void _injectWarning(String message) {
    final aiController =
        Provider.of<AiShoppingController>(context, listen: false);
    aiController.injectMessage(AiChatMessage(
      id: 'cart_warn_${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      message: message,
    ));
  }

  void _onIncrementQty() {
    final product = widget.product;
    if (!product.isDigital) {
      final matched = _matchedPhysicalVariation();
      final int effectiveStock = _effectiveStockFor(matched);
      if (_quantity >= effectiveStock) {
        _injectWarning(getTranslated('out_of_stock', context) ?? 'Out of Stock');
        return;
      }
    }
    setState(() => _quantity++);
  }

  Future<void> _addToCart(BuildContext context, {int buyNow = 0}) async {
    if (_isAddingToCart) return;
    final product = widget.product;

    final aiController =
        Provider.of<AiShoppingController>(context, listen: false);
    final cartController =
        Provider.of<CartController>(context, listen: false);

    // Capture all translated strings before any async gap
    final selectVariationText =
        getTranslated('select_variation_first', context) ??
            'Please select your options';
    final selectDigitalText =
        getTranslated('select_digital_variation', context) ??
            'Please select a digital variation';
    final outOfStockText =
        getTranslated('out_of_stock', context) ?? 'Out of Stock';
    final minQtyText =
        '${getTranslated('to_order_this_item_minimum_order_quantity_is', context) ?? 'Minimum order quantity is'} ${product.minimumOrderQty ?? 1}';
    final addingText = getTranslated('adding_to_your_cart', context) ??
        'Adding to your cart…';
    final successText =
        getTranslated('added_to_cart_successfully', context) ??
            'Successfully added!';

    AiShoppingVariationModel? matched;
    String colorName = '';
    String colorCode = '';
    String? variantKey;
    double? digitalVariantPrice;

    if (product.isDigital) {
      if (product.digitalVariations.isNotEmpty && _selectedDigitalIndex < 0) {
        _injectWarning(selectDigitalText);
        return;
      }
      if (_selectedDigitalIndex >= 0) {
        variantKey =
            product.digitalVariations[_selectedDigitalIndex].variantKey;
        digitalVariantPrice =
            product.digitalVariations[_selectedDigitalIndex].price;
      }
    } else {
      if (product.hasPhysicalVariations && _buildVariationType().isEmpty) {
        _injectWarning(selectVariationText);
        return;
      }

      matched = _matchedPhysicalVariation();
      final int effectiveStock = _effectiveStockFor(matched);
      final int minQty = product.minimumOrderQty ?? 1;

      if (effectiveStock <= 0 || effectiveStock < minQty) {
        _injectWarning(outOfStockText);
        return;
      }

      if (_quantity < minQty) {
        _injectWarning(minQtyText);
        return;
      }

      if (_quantity > effectiveStock) {
        _injectWarning(outOfStockText);
        return;
      }

      if (_selectedColorIndex >= 0 && product.hasColors) {
        colorName = product.colors[_selectedColorIndex].name ?? '';
        colorCode = product.colors[_selectedColorIndex].code ?? '';
      }
    }

    final cartBody = CartModelBody(
      productId: product.id,
      quantity: _quantity,
      variant: colorName,
      color: colorCode,
      variation: matched != null
          ? Variation(
              type: matched.type,
              price: matched.price,
              sku: matched.sku,
              qty: matched.qty,
            )
          : null,
      variantKey: variantKey,
      digitalVariantPrice: digitalVariantPrice,
    );

    final choiceOptions = product.choiceOptions
        .map((o) => ChoiceOptions(
              name: o.name,
              title: o.title,
              options: o.options,
            ))
        .toList();

    final loadingMsgId =
        'cart_loading_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isAddingToCart = true);
    aiController.injectMessage(AiChatMessage(
      id: loadingMsgId,
      isUser: false,
      message: addingText,
    ));

    bool success = false;
    try {
      final response = await cartController.addToCartAPI(
        cartBody,
        context,
        choiceOptions,
        _selectedVariationIndices,
        buyNow: buyNow,
        shouldPop: false,
        showSuccessToast: false,
      );

      if (response.response != null &&
          response.response!.statusCode == 200) {
        success = true;
      }

      if (buyNow == 1 && success) {
        RouterHelper.getDashboardRoute(
            action: RouteAction.pushNamedAndRemoveUntil);
        RouterHelper.getCartScreenRoute(action: RouteAction.push);
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
        aiController.removeMessage(loadingMsgId);
        if (success && buyNow != 1) {
          aiController.injectMessage(AiChatMessage(
            id: 'cart_success_${DateTime.now().millisecondsSinceEpoch}',
            isUser: false,
            message: successText,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final discountedUnit = _discountedUnitPrice(context);
    final bool isOutOfStock = _isSelectedVariationOutOfStock;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuickViewHeader(
              product: product,
              discountedUnitPrice: discountedUnit,
              baseUnitPrice: _basePrice,
              quantity: _quantity,
              onDismiss: widget.onDismiss,
              isOutOfStock: isOutOfStock,
            ),
            if (product.hasColors) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _QuickViewColors(
                colors: product.colors
                    .map((c) => (name: c.name, code: c.code))
                    .toList(),
                selectedIndex: _selectedColorIndex,
                onSelect: (i) => setState(() => _selectedColorIndex = i),
              ),
            ],
            if (product.hasChoiceOptions && !product.isDigital) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ...List.generate(product.choiceOptions.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < product.choiceOptions.length - 1
                        ? Dimensions.paddingSizeSmall
                        : 0,
                  ),
                  child: _QuickViewChoiceOption(
                    title: product.choiceOptions[i].title?.toCapitalized() ??
                        product.choiceOptions[i].name ??
                        '',
                    options: product.choiceOptions[i].options,
                    selectedIndex: _selectedVariationIndices[i],
                    onSelect: (j) =>
                        setState(() => _selectedVariationIndices[i] = j),
                  ),
                );
              }),
            ],
            if (product.isDigital && product.digitalVariations.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _QuickViewDigitalVariations(
                variations: product.digitalVariations,
                selectedIndex: _selectedDigitalIndex,
                onSelect: (i) => setState(() => _selectedDigitalIndex = i),
              ),
            ],
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _QuickViewQty(
              quantity: _quantity,
              onDecrement: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
              onIncrement: _onIncrementQty,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _QuickViewButtons(
              buyNow: widget.buyNow,
              isLoading: _isAddingToCart,
              disabled: isOutOfStock,
              onAddToCart: () => _addToCart(context, buyNow: 0),
              onBuyNow: () => _addToCart(context, buyNow: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickViewHeader extends StatelessWidget {
  final AiShoppingProductModel product;
  final double discountedUnitPrice;
  final double baseUnitPrice;
  final int quantity;
  final VoidCallback? onDismiss;
  final bool isOutOfStock;

  const _QuickViewHeader({
    required this.product,
    required this.discountedUnitPrice,
    required this.baseUnitPrice,
    required this.quantity,
    required this.isOutOfStock,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final double totalPrice = discountedUnitPrice * quantity;
    final double originalTotal = baseUnitPrice * quantity;
    final bool showStrikethrough =
        product.hasDiscount && originalTotal != totalPrice;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            width: 90,
            height: 90,
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: CustomImageWidget(
              image: product.thumbnailFullUrl ?? product.thumbnail ?? '',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: titleHeader.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDismiss != null) ...[
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.10),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 13,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                PriceConverter.convertPrice(context, totalPrice),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (showStrikethrough) ...[
                Text(
                  PriceConverter.convertPrice(context, originalTotal),
                  style: titilliumRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Theme.of(context).hintColor,
                  ),
                ),
              ],
              if (isOutOfStock) ...[
                const SizedBox(height: 2),
                Text(
                  getTranslated('out_of_stock', context) ?? 'Out of Stock',
                  style: titilliumBold.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickViewColors extends StatelessWidget {
  final List<({String? name, String? code})> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuickViewColors({
    required this.colors,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${getTranslated('color', context) ?? 'Color'}:',
          style: textMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(colors.length, (i) {
              final code = colors[i].code ?? '#cccccc';
              Color swatch = Colors.grey;
              try {
                swatch =
                    Color(int.parse('0xff${code.replaceAll('#', '')}'));
              } catch (_) {}
              final bool isSelected = i == selectedIndex;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                    ),
                  ),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: swatch,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _QuickViewChoiceOption extends StatelessWidget {
  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuickViewChoiceOption({
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$title:',
          style: textMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(options.length, (i) {
              final bool isSelected = i == selectedIndex;
              return InkWell(
                onTap: () => onSelect(i),
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    color: isSelected
                        ? Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.08)
                        : Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withValues(alpha: 0.4),
                    border: Border.all(
                      width: 1,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Text(
                    options[i].trim(),
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _QuickViewDigitalVariations extends StatelessWidget {
  final List<AiShoppingDigitalVariationModel> variations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuickViewDigitalVariations({
    required this.variations,
    required this.selectedIndex,
    required this.onSelect,
  });

  // Group flat variations by the file-type prefix of variantKey (e.g. "pdf-standard" → "pdf").
  Map<String, List<int>> _grouped() {
    final Map<String, List<int>> groups = {};
    for (int i = 0; i < variations.length; i++) {
      final key = variations[i].variantKey;
      final dashIdx = key.indexOf('-');
      final type = dashIdx >= 0 ? key.substring(0, dashIdx) : key;
      groups.putIfAbsent(type, () => []).add(i);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped();
    final types = groups.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(types.length, (groupIdx) {
        final type = types[groupIdx];
        final indices = groups[type]!;
        final typeLabel =
            type.isNotEmpty ? type[0].toUpperCase() + type.substring(1) : type;

        return Padding(
          padding: EdgeInsets.only(
            bottom: groupIdx < types.length - 1
                ? Dimensions.paddingSizeLarge
                : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$typeLabel ',
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: indices.map((flatIdx) {
                    final v = variations[flatIdx];
                    final bool isSelected = flatIdx == selectedIndex;
                    return InkWell(
                      onTap: () => onSelect(flatIdx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: isSelected
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : Theme.of(context).hintColor.withAlpha(30),
                          border: Border.all(
                            width: 1,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          v.label.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.color,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _QuickViewQty extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuickViewQty({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${getTranslated('qty', context) ?? 'Qty'}:',
          style: textMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        _StepperCell(
          width: 36,
          onTap: quantity > 1 ? onDecrement : null,
          child: Icon(
            Icons.remove,
            size: 16,
            color: quantity > 1
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).hintColor.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        _StepperCell(
          width: 44,
          child: Text(
            quantity.toString(),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        _StepperCell(
          width: 36,
          onTap: onIncrement,
          child: Icon(
            Icons.add,
            size: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

class _StepperCell extends StatelessWidget {
  final double width;
  final Widget child;
  final VoidCallback? onTap;

  const _StepperCell({
    required this.width,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: child,
      ),
    );
  }
}

class _QuickViewButtons extends StatelessWidget {
  final bool buyNow;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _QuickViewButtons({
    required this.buyNow,
    required this.onAddToCart,
    required this.onBuyNow,
    this.isLoading = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isLoading || disabled;
    return Row(
      children: [
        Expanded(
          child: Opacity(
            opacity: isDisabled ? 0.4 : 1.0,
            child: GestureDetector(
              onTap: isDisabled ? null : onAddToCart,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusHundred),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  getTranslated('add_to_cart', context) ?? 'Add to Cart',
                  style: titleHeader.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Opacity(
            opacity: isDisabled ? 0.4 : 1.0,
            child: GestureDetector(
              onTap: isDisabled ? null : onBuyNow,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B2E6B), Color(0xFF3A5FC1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusHundred),
                ),
                child: Text(
                  getTranslated('buy_now', context) ?? 'Buy Now',
                  style: titleHeader.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
