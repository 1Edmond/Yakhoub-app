import 'dart:io';

import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_cart_selection_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_send_message_response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_session_model.dart';

abstract class AiShoppingServiceInterface {
  Future<AiShoppingSessionModel> startSession({String? guestId});
  Future<List<AiShoppingSessionModel>> listSessions({String? guestId});
  Future<AiShoppingSessionModel> getSession(int id, {String? guestId});
  Future<void> deleteSession(int id, {String? guestId});
  Future<AiShoppingSendMessageResponse> sendMessage(
    int sessionId, {
    required String message,
    String? guestId,
    String? imageUrl,
    List<AiShoppingCartSelection>? cartSelections,
  });
  Future<String> uploadImage(File image, {String? guestId});
}
