import 'user_model.dart';
import 'message_model.dart';

class ChatModel {
  final String id;
  final List<UserModel> participants;
  final String? name; // Pour les groupes
  final MessageModel? lastMessage;
  final DateTime lastActivity;
  final int unreadCount;
  final bool isGroup;

  ChatModel({
    required this.id,
    required this.participants,
    this.name,
    this.lastMessage,
    required this.lastActivity,
    this.unreadCount = 0,
    this.isGroup = false,
  });
}