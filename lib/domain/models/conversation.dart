import 'package:hive/hive.dart';

part 'conversation.g.dart';

@HiveType(typeId: 2)
class Conversation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final String? selectedModel;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.selectedModel,
  });

  factory Conversation.create({
    String? title,
    String? selectedModel,
  }) {
    final now = DateTime.now();
    return Conversation(
      id: now.millisecondsSinceEpoch.toString(),
      title: title ?? 'New Conversation',
      createdAt: now,
      updatedAt: now,
      selectedModel: selectedModel,
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? selectedModel,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      selectedModel: selectedModel ?? this.selectedModel,
    );
  }
}
