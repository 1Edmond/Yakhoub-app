import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_chat_message_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_action_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_cart_selection_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_preselect_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_send_message_response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_session_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/services/ai_shopping_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiShoppingController extends ChangeNotifier {
  final AiShoppingServiceInterface aiShoppingServiceInterface;

  AiShoppingController({required this.aiShoppingServiceInterface});

  final List<AiChatMessage> _messages = [];
  AiShoppingSessionModel? _session;
  bool _isInitializing = false;
  String? _guestId;
  File? _pendingImage;
  String? _pendingImageUrl;
  bool _isUploadingImage = false;
  List<AiShoppingSessionModel> _allSessions = [];
  bool _isLoadingSessions = false;

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  AiShoppingSessionModel? get session => _session;
  bool get isInitializing => _isInitializing;
  File? get pendingImage => _pendingImage;
  String? get pendingImageUrl => _pendingImageUrl;
  bool get isUploadingImage => _isUploadingImage;
  bool get isTyping => _messages.any((m) => m.isLoading);
  List<AiShoppingSessionModel> get allSessions =>
      List.unmodifiable(_allSessions);
  bool get isLoadingSessions => _isLoadingSessions;
  int? get currentSessionId => _session?.id;

  Future<void> initChatSession() async {
    if (_isInitializing) return;
    _isInitializing = true;
    notifyListeners();
    try {
      await _createSession();
    } catch (_) {
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _createSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn =
        prefs.getString(AppConstants.userLoginToken) != null;
    if (_guestId == null && !isLoggedIn) {
      _guestId = prefs.getString(AppConstants.guestId);
    }
    final newSession = await aiShoppingServiceInterface.startSession(
      guestId: isLoggedIn ? null : _guestId,
    );
    _session = newSession;
    if (!isLoggedIn && _session!.guestId != null) {
      _guestId = _session!.guestId;
    }
  }

  Future<void> _loadSessionHistory() async {
    if (_session == null) return;
    try {
      final full = await aiShoppingServiceInterface.getSession(
        _session!.id,
        guestId: _guestId,
      );
      _session = full;
      _messages.clear();
      for (final m in full.messages) {
        _messages.add(AiChatMessage(
          id: 'hist_${m.id}',
          isUser: m.role == 'user',
          message: m.content,
          imageUrl: m.imageUrl,
          products: m.products.isEmpty ? null : m.products,
        ));
      }
    } catch (_) {}
  }

  Future<void> loadCurrentSession() async {
    if (_session == null) return;
    _isInitializing = true;
    notifyListeners();
    try {
      await _loadSessionHistory();
    } catch (_) {
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text,
      {List<AiShoppingCartSelection>? cartSelections}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && _pendingImage == null && _pendingImageUrl == null) {
      return;
    }

    if (_session == null) {
      try {
        await _createSession();
      } catch (_) {
        return;
      }
    }

    // Upload pending image before sending
    if (_pendingImage != null && _pendingImageUrl == null) {
      _isUploadingImage = true;
      notifyListeners();
      try {
        _pendingImageUrl = await aiShoppingServiceInterface.uploadImage(
          _pendingImage!,
          guestId: _guestId,
        );
      } catch (_) {
        _pendingImage = null;
        _isUploadingImage = false;
        showCustomSnackBarWidget(
          getTranslated('image_upload_failed', Get.context!) ??
              'Image upload failed',
          Get.context!,
          snackBarType: SnackBarType.error,
        );
        notifyListeners();
        return;
      }
      _isUploadingImage = false;
      notifyListeners();
    }

    final String msgId = '${DateTime.now().millisecondsSinceEpoch}_user';
    _messages.add(AiChatMessage(
      id: msgId,
      isUser: true,
      message: trimmed.isEmpty ? null : trimmed,
      imageUrl: _pendingImageUrl,
    ));

    final String loadingId = '${DateTime.now().millisecondsSinceEpoch}_typing';
    _messages.add(AiChatMessage(id: loadingId, isUser: false, isLoading: true));

    final String? sentImageUrl = _pendingImageUrl;
    _pendingImage = null;
    _pendingImageUrl = null;
    notifyListeners();

    try {
      final AiShoppingSendMessageResponse response =
          await aiShoppingServiceInterface.sendMessage(
        _session!.id,
        message: trimmed.isEmpty ? '.' : trimmed,
        guestId: _guestId,
        imageUrl: sentImageUrl,
        cartSelections: cartSelections,
      );

      _messages.removeWhere((m) => m.id == loadingId);

      if (response.reply.isNotEmpty) {
        _messages.add(AiChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}_reply',
          isUser: false,
          message: response.reply,
          products: response.products.isEmpty ? null : response.products,
          actions: response.actions.isEmpty ? null : response.actions,
        ));
      }

      await _handleActions(response);
    } catch (_) {
      _messages.removeWhere((m) => m.id == loadingId);
      _messages.add(AiChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_err',
        isUser: false,
        message: getTranslated('ai_error_retry', Get.context!) ??
            'Something went wrong. Please try again.',
      ));
    }
    notifyListeners();
  }

  Future<void> _handleActions(AiShoppingSendMessageResponse response) async {
    for (final action in response.actions) {
      switch (action.type) {
        case AiShoppingActionType.selectVariation:
        case AiShoppingActionType.needsConfirmation:
          final product = _findProduct(response.products, action.productId);
          if (product != null) {
            _messages.add(AiChatMessage(
              id: '${DateTime.now().millisecondsSinceEpoch}_card_${product.id}',
              isUser: false,
              selectedProduct: product,
              preselect: action.preselect,
              buyNow: action.buyNow ?? false,
            ));
          }
          break;

        case AiShoppingActionType.added:
        case AiShoppingActionType.updated:
          if (action.productId != null) {
            // The backend already performed the cart add/update itself;
            // just refresh the local cart list to reflect it.
            await Provider.of<CartController>(Get.context!, listen: false)
                .getCartData(Get.context!);
          }
          break;

        case AiShoppingActionType.checkout:
          _messages.add(AiChatMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}_checkout',
            isUser: false,
            checkoutUrl: action.url,
          ));
          break;

        case AiShoppingActionType.minimumNotMet:
          if (action.shops != null && action.shops!.isNotEmpty) {
            _messages.add(AiChatMessage(
              id: '${DateTime.now().millisecondsSinceEpoch}_minnotmet',
              isUser: false,
              minimumNotMet: action.shops,
            ));
          }
          break;

        case AiShoppingActionType.unknown:
          break;
      }
    }
  }

  AiShoppingProductModel? _findProduct(
      List<AiShoppingProductModel> products, int? productId) {
    if (productId == null) return null;
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> confirmCard(
    AiShoppingCartSelection selection, {
    required bool buyNow,
    required String messageText,
  }) async {
    await sendMessage(
      messageText,
      cartSelections: [selection],
    );
  }

  void selectProduct(AiShoppingProductModel product,
      {AiShoppingPreselectModel? preselect, bool buyNow = false}) {
    _messages.add(AiChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_card_${product.id}',
      isUser: false,
      selectedProduct: product,
      preselect: preselect,
      buyNow: buyNow,
    ));
    notifyListeners();
  }

  void removeMessage(String id) {
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void injectMessage(AiChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    _pendingImage = File(picked.path);
    _pendingImageUrl = null;
    notifyListeners();
  }

  void clearPendingImage() {
    _pendingImage = null;
    _pendingImageUrl = null;
    notifyListeners();
  }

  Future<void> loadAllSessions() async {
    _isLoadingSessions = true;
    notifyListeners();
    try {
      _allSessions = await aiShoppingServiceInterface.listSessions(
        guestId: _guestId,
      );
    } catch (_) {}
    _isLoadingSessions = false;
    notifyListeners();
  }

  Future<void> deleteSessionById(int id) async {
    try {
      await aiShoppingServiceInterface.deleteSession(id, guestId: _guestId);
      _allSessions.removeWhere((s) => s.id == id);
      if (_session?.id == id) {
        _session = null;
        _messages.clear();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> startNewSession() async {
    _messages.clear();
    _session = null;
    notifyListeners();
    await initChatSession();
  }

  Future<void> switchToSession(AiShoppingSessionModel session) async {
    if (_session?.id == session.id) return;
    _messages.clear();
    _session = session;
    notifyListeners();
    await _loadSessionHistory();
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  void clearSession() {
    _messages.clear();
    _session = null;
    _allSessions = [];
    _guestId = null;
    notifyListeners();
  }
}
