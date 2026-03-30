import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';

/// Hive database service for storing conversations and messages
class DatabaseService {
  static const String _conversationsBoxName = 'conversations';
  static const String _messagesBoxName = 'messages';

  late Box<Conversation> _conversationsBox;
  late Box<Message> _messagesBox;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    // Register adapters
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(MessageRoleAdapter());
    Hive.registerAdapter(ConversationAdapter());

    // Get app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    
    // Initialize Hive
    await Hive.initFlutter(appDir.path);

    // Open boxes
    _conversationsBox = await Hive.openBox<Conversation>(_conversationsBoxName);
    _messagesBox = await Hive.openBox<Message>(_messagesBoxName);
  }

  // ============ Conversations ============

  /// Get all conversations sorted by updated date (newest first)
  List<Conversation> getAllConversations() {
    final conversations = _conversationsBox.values.toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  /// Get a single conversation by ID
  Conversation? getConversation(String id) {
    return _conversationsBox.get(id);
  }

  /// Create a new conversation
  Future<void> createConversation(Conversation conversation) async {
    await _conversationsBox.put(conversation.id, conversation);
  }

  /// Update an existing conversation
  Future<void> updateConversation(Conversation conversation) async {
    await _conversationsBox.put(conversation.id, conversation);
  }

  /// Delete a conversation and all its messages
  Future<void> deleteConversation(String id) async {
    await _conversationsBox.delete(id);
    await deleteMessagesForConversation(id);
  }

  // ============ Messages ============

  /// Get all messages for a conversation, sorted by timestamp
  List<Message> getMessagesForConversation(String conversationId) {
    final messages = _messagesBox.values
        .where((m) => m.conversationId == conversationId)
        .toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  /// Add a message to a conversation
  Future<void> addMessage(Message message) async {
    await _messagesBox.put(message.id, message);
    
    // Update the conversation's updated timestamp
    if (message.conversationId != null) {
      final conversation = _conversationsBox.get(message.conversationId);
      if (conversation != null) {
        final updated = conversation.copyWith(
          updatedAt: DateTime.now(),
          // Update title if this is the first user message
          title: conversation.title == 'New Conversation' && 
                 message.role == MessageRole.user
              ? _generateTitle(message.content)
              : conversation.title,
        );
        await _conversationsBox.put(conversation.id, updated);
      }
    }
  }

  /// Update an existing message
  Future<void> updateMessage(Message message) async {
    await _messagesBox.put(message.id, message);
  }

  /// Delete all messages for a conversation
  Future<void> deleteMessagesForConversation(String conversationId) async {
    final messages = getMessagesForConversation(conversationId);
    for (final message in messages) {
      await _messagesBox.delete(message.id);
    }
  }

  /// Delete a single message
  Future<void> deleteMessage(String messageId) async {
    await _messagesBox.delete(messageId);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _conversationsBox.clear();
    await _messagesBox.clear();
  }

  /// Generate a title from the first message content
  String _generateTitle(String content) {
    // Take first 50 characters and remove newlines
    final title = content.replaceAll('\n', ' ').trim();
    return title.length > 50 ? '${title.substring(0, 47)}...' : title;
  }

  /// Close the database
  Future<void> close() async {
    await _conversationsBox.close();
    await _messagesBox.close();
  }
}
