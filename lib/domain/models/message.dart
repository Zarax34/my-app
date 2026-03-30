import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
enum MessageRole {
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
  @HiveField(2)
  system,
}

@HiveType(typeId: 1)
class Message {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final MessageRole role;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? conversationId;

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.conversationId,
  });

  factory Message.user({
    required String content,
    String? conversationId,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
      conversationId: conversationId,
    );
  }

  factory Message.assistant({
    required String content,
    String? conversationId,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      conversationId: conversationId,
    );
  }

  Message copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    String? conversationId,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  Map<String, dynamic> toOllamaFormat() {
    return {
      'role': role.name,
      'content': content,
    };
  }
}
