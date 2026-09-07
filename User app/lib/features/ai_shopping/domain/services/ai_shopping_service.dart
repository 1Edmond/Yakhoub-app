import 'dart:io';

import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_cart_selection_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_send_message_response_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_session_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/repository/ai_shopping_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/services/ai_shopping_service_interface.dart';

class AiShoppingService implements AiShoppingServiceInterface {
  final AiShoppingRepositoryInterface aiShoppingRepositoryInterface;

  AiShoppingService({required this.aiShoppingRepositoryInterface});

  @override
  Future<AiShoppingSessionModel> startSession({String? guestId}) =>
      aiShoppingRepositoryInterface.startSession(guestId: guestId);

  @override
  Future<List<AiShoppingSessionModel>> listSessions({String? guestId}) =>
      aiShoppingRepositoryInterface.listSessions(guestId: guestId);

  @override
  Future<AiShoppingSessionModel> getSession(int id, {String? guestId}) =>
      aiShoppingRepositoryInterface.getSession(id, guestId: guestId);

  @override
  Future<void> deleteSession(int id, {String? guestId}) =>
      aiShoppingRepositoryInterface.deleteSession(id, guestId: guestId);

  @override
  Future<AiShoppingSendMessageResponse> sendMessage(
    int sessionId, {
    required String message,
    String? guestId,
    String? imageUrl,
    List<AiShoppingCartSelection>? cartSelections,
  }) =>
      aiShoppingRepositoryInterface.sendMessage(
        sessionId,
        message: message,
        guestId: guestId,
        imageUrl: imageUrl,
        cartSelections: cartSelections,
      );

  @override
  Future<String> uploadImage(File image, {String? guestId}) =>
      aiShoppingRepositoryInterface.uploadImage(image, guestId: guestId);
}
