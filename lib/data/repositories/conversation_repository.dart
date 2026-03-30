import '../domain/models/conversation.dart';
import '../domain/models/message.dart';
import '../data/storage/database_service.dart';

/// Repository for managing conversations and messages locally
class ConversationRepository {
  final DatabaseService _database;

  ConversationRepository({required DatabaseService database})
      : _database = database;

  /// Get all conversations
  List<Conversation> getAllConversations() {
    return _database.getAllConversations();
  }

  /// Get a single conversation
  Conversation? getConversation(String id) {
    return _database.getConversation(id);
  }

  /// Create a new conversation
  Future<void> createConversation(Conversation conversation) async {
    await _database.createConversation(conversation);
  }

  /// Update a conversation
  Future<void> updateConversation(Conversation conversation) async {
    await _database.updateConversation(conversation);
  }

  /// Delete a conversation
  Future<void> deleteConversation(String id) async {
    await _database.deleteConversation(id);
  }

  /// Get messages for a conversation
  List<Message> getMessages(String conversationId) {
    return _database.getMessagesForConversation(conversationId);
  }

  /// Add a message to a conversation
  Future<void> addMessage(Message message) async {
    await _database.addMessage(message);
  }

  /// Update a message
  Future<void> updateMessage(Message message) async {
    await _database.updateMessage(message);
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _database.deleteMessage(messageId);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _database.clearAll();
  }
}
