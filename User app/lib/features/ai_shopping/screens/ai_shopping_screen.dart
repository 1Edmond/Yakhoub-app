import 'dart:io' as dart_io;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/controllers/ai_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_chat_message_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_action_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_preselect_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/widgets/ai_chat_receiver_bubble_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/widgets/ai_chat_sender_bubble_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/screens/ai_sessions_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/widgets/ai_product_quick_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AiShoppingScreen extends StatefulWidget {
  const AiShoppingScreen({super.key});

  @override
  State<AiShoppingScreen> createState() => _AiShoppingScreenState();
}

class _AiShoppingScreenState extends State<AiShoppingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<AiShoppingController>(context, listen: false);
      if (controller.currentSessionId == null) {
        controller.initChatSession();
      } else {
        controller.loadCurrentSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: getTranslated('hexa_ai', context) ?? 'HexaAi',
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiSessionsScreen()),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: Consumer<AiShoppingController>(
            builder: (context, controller, _) {
              if (controller.isInitializing) {
                return const _ChatLoadingShimmer();
              }
              if (controller.messages.isEmpty) {
                return const _AiShoppingWelcome();
              }
              return _AiShoppingChatList(messages: controller.messages);
            },
          ),
        ),
        const _AiShoppingInputBar(),
        SizedBox(
            height: MediaQuery.of(context).padding.bottom +
                Dimensions.paddingSizeSmall),
      ]),
    );
  }
}

class _AiShoppingWelcome extends StatelessWidget {
  const _AiShoppingWelcome();

  static const Map<String, String> _suggestions = {
    'ai_shopping_suggestion_best_deals': "Show me today's best deals",
    'ai_shopping_suggestion_budget_phone': 'Suggest a good phone under 1000',
    'ai_shopping_suggestion_brands': 'What brands do you have',
    'ai_shopping_suggestion_trending': 'Show me trending products',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AiWelcomeBubble(
            message: getTranslated('ai_shopping_welcome_message', context) ??
                "👋 Hi! I'm your shopping assistant at 6Valley. I can help you find products, compare options, discover today's deals, and add items to your cart. What are you looking for today?",
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(
            getTranslated('try_asking', context) ?? 'Try asking',
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ..._suggestions.entries.map((entry) => Padding(
                padding:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: _AiSuggestionChip(
                  text: getTranslated(entry.key, context) ?? entry.value,
                ),
              )),
        ],
      ),
    );
  }
}

class _AiWelcomeBubble extends StatelessWidget {
  final String message;

  const _AiWelcomeBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(child: AiChatReceiverBubble(message: message)),
      ],
    );
  }
}

class _AiSuggestionChip extends StatelessWidget {
  final String text;

  const _AiSuggestionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      onTap: () => Provider.of<AiShoppingController>(context, listen: false)
          .sendMessage(text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

AiShoppingPreselectModel? _preselectForProduct(
    List<AiShoppingActionModel>? actions, AiShoppingProductModel product) {
  if (actions == null) return null;
  AiShoppingActionModel? matched;
  for (final action in actions) {
    if (action.productId == product.id && action.quantity != null) {
      matched = action;
      break;
    }
  }
  if (matched == null) return null;
  return AiShoppingPreselectModel(
    color: matched.preselect?.color,
    choices: matched.preselect?.choices,
    qty: matched.quantity,
    variantKey: matched.preselect?.variantKey,
  );
}

class _AiShoppingChatList extends StatefulWidget {
  final List<AiChatMessage> messages;

  const _AiShoppingChatList({required this.messages});

  @override
  State<_AiShoppingChatList> createState() => _AiShoppingChatListState();
}

class _AiShoppingChatListState extends State<_AiShoppingChatList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_AiShoppingChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final msg = widget.messages[index];

        if (msg.isLoading) {
          return const Padding(
            padding: EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            child: _AiTypingBubble(),
          );
        }

        if (msg.selectedProduct != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            child: AiProductQuickView(
              key: ValueKey(msg.id),
              product: msg.selectedProduct!,
              messageId: msg.id,
              preselect: msg.preselect,
              buyNow: msg.buyNow,
              onDismiss: () =>
                  Provider.of<AiShoppingController>(context, listen: false)
                      .removeMessage(msg.id),
            ),
          );
        }

        if (msg.checkoutUrl != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            child: const _AiCheckoutBubble(),
          );
        }

        if (msg.minimumNotMet != null && msg.minimumNotMet!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            child: _AiMinimumNotMetBubble(shops: msg.minimumNotMet!),
          );
        }

        if (msg.isUser) {
          return _AiSenderBubbleWithImage(
            message: msg.message,
            imageUrl: msg.imageUrl,
          );
        }

        return AiChatReceiverBubble(
          boldTitle: msg.boldTitle,
          body: msg.body,
          message: msg.message,
          products: msg.products,
          onProductTap: (product) =>
              Provider.of<AiShoppingController>(context, listen: false)
                  .selectProduct(product,
                      preselect: _preselectForProduct(msg.actions, product)),
        );
      },
    );
  }
}

class _AiTypingBubble extends StatefulWidget {
  const _AiTypingBubble();

  @override
  State<_AiTypingBubble> createState() => _AiTypingBubbleState();
}

class _AiTypingBubbleState extends State<_AiTypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusSmall),
            topRight: Radius.circular(Dimensions.radiusLarge),
            bottomLeft: Radius.circular(Dimensions.radiusLarge),
            bottomRight: Radius.circular(Dimensions.radiusLarge),
          ),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final double phase = ((_controller.value * 3) - i).clamp(0.0, 1.0);
                final double opacity =
                    (0.3 + 0.7 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2))
                        .clamp(0.3, 1.0);
                return Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _AiSenderBubbleWithImage extends StatelessWidget {
  final String? message;
  final String? imageUrl;

  const _AiSenderBubbleWithImage({this.message, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return AiChatSenderBubble(message: message ?? '');
    }
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 60, bottom: Dimensions.paddingSizeLarge),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusLarge),
            topRight: Radius.circular(Dimensions.radiusLarge),
            bottomLeft: Radius.circular(Dimensions.radiusLarge),
            bottomRight: Radius.circular(Dimensions.radiusSmall),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                image: imageUrl!,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall),
                child: Text(
                  message!,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AiCheckoutBubble extends StatelessWidget {
  const _AiCheckoutBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getTranslated('your_order_is_ready', context) ??
                  'Your order is ready!',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            GestureDetector(
              onTap: () {
                RouterHelper.getDashboardRoute(
                    action: RouteAction.pushNamedAndRemoveUntil);
                RouterHelper.getCartScreenRoute(action: RouteAction.push);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                  vertical: 14,
                ),
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
                  getTranslated('proceed_to_checkout', context) ??
                      'Proceed to Checkout',
                  style: titleHeader.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiMinimumNotMetBubble extends StatelessWidget {
  final List shops;

  const _AiMinimumNotMetBubble({required this.shops});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusSmall),
            topRight: Radius.circular(Dimensions.radiusLarge),
            bottomLeft: Radius.circular(Dimensions.radiusLarge),
            bottomRight: Radius.circular(Dimensions.radiusLarge),
          ),
          border: Border.all(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getTranslated('minimum_order_not_met', context) ??
                  'Minimum order not met',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            ...shops.map((shop) => Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                  child: Text(
                    '${shop.shop}: ${shop.current} / ${shop.required} (need ${shop.shortfall} more)',
                    style: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.5,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _AiShoppingInputBar extends StatefulWidget {
  const _AiShoppingInputBar();

  @override
  State<_AiShoppingInputBar> createState() => _AiShoppingInputBarState();
}

class _AiShoppingInputBarState extends State<_AiShoppingInputBar> {
  final TextEditingController _queryController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(() {
      final hasText = _queryController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onSend() {
    final query = _queryController.text.trim();
    final controller =
        Provider.of<AiShoppingController>(context, listen: false);
    final hasImage =
        controller.pendingImage != null || controller.pendingImageUrl != null;
    if (query.isEmpty && !hasImage) return;
    if (query.isEmpty && hasImage) {
      showCustomSnackBarWidget(
        getTranslated('add_message_with_image', context) ??
            'Please write a message before sending the image',
        context,
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    controller.sendMessage(query);
    _queryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiShoppingController>(
      builder: (context, controller, _) {
        return Padding(
          padding: EdgeInsets.only(
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.pendingImage != null) ...[
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                _PendingImagePreview(
                  imagePath: controller.pendingImage!.path,
                  isUploading: controller.isUploadingImage,
                  onRemove: controller.clearPendingImage,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusHundred),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(children: [
                  GestureDetector(
                    onTap: controller.isUploadingImage ? null : controller.pickImage,
                    child: Icon(
                      Icons.image_search_rounded,
                      color: controller.isUploadingImage
                          ? Theme.of(context).hintColor.withValues(alpha: 0.4)
                          : Theme.of(context).hintColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _onSend(),
                      decoration: InputDecoration(
                        hintText:
                            getTranslated('write_me_about_your_item', context) ??
                                'Write me about your item',
                        hintStyle: titilliumRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  if (_hasText || controller.pendingImage != null) ...[
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    GestureDetector(
                      onTap: controller.isUploadingImage ? null : _onSend,
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: controller.isUploadingImage
                              ? Theme.of(context).hintColor.withValues(alpha: 0.4)
                              : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: controller.isUploadingImage
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingImagePreview extends StatelessWidget {
  final String imagePath;
  final bool isUploading;
  final VoidCallback onRemove;

  const _PendingImagePreview({
    required this.imagePath,
    required this.isUploading,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Image.file(
            dart_io.File(imagePath),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        if (isUploading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
          ),
        if (!isUploading)
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }
}

class _ChatLoadingShimmer extends StatelessWidget {
  const _ChatLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).hintColor.withValues(alpha: 0.18);
    final highlight = Theme.of(context).hintColor.withValues(alpha: 0.06);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: const [
          _BubbleSkeleton(isUser: false, width: 240),
          SizedBox(height: Dimensions.paddingSizeLarge),
          _BubbleSkeleton(isUser: true, width: 180),
          SizedBox(height: Dimensions.paddingSizeLarge),
          _BubbleSkeleton(isUser: false, width: 200),
          SizedBox(height: Dimensions.paddingSizeLarge),
          _BubbleSkeleton(isUser: false, width: 160),
          SizedBox(height: Dimensions.paddingSizeLarge),
          _BubbleSkeleton(isUser: true, width: 140),
        ],
      ),
    );
  }
}

class _BubbleSkeleton extends StatelessWidget {
  final bool isUser;
  final double width;

  const _BubbleSkeleton({required this.isUser, required this.width});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(Dimensions.radiusLarge),
                topRight: const Radius.circular(Dimensions.radiusLarge),
                bottomLeft: Radius.circular(
                    isUser ? Dimensions.radiusLarge : Dimensions.radiusSmall),
                bottomRight: Radius.circular(
                    isUser ? Dimensions.radiusSmall : Dimensions.radiusLarge),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: width * 0.55,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
        ],
      ),
    );
  }
}
