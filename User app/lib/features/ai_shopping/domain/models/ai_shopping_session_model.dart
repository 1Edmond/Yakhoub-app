import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_history_message_model.dart';

class AiShoppingSessionModel {
  final int id;
  final int? customerId;
  final String? guestId;
  final String? title;
  final String locale;
  final String lastActivityAt;
  final String createdAt;
  final String updatedAt;
  final int? messageCount;
  final List<AiShoppingHistoryMessage> messages;

  const AiShoppingSessionModel({
    required this.id,
    this.customerId,
    this.guestId,
    this.title,
    required this.locale,
    required this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount,
    this.messages = const [],
  });

  factory AiShoppingSessionModel.fromJson(Map<String, dynamic> json) {
    return AiShoppingSessionModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'],
      guestId: json['guest_id'],
      title: json['title'],
      locale: json['locale'] ?? 'en',
      lastActivityAt: json['last_activity_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      messageCount: json['messages_count'],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => AiShoppingHistoryMessage.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
