import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ollama_repository.dart';
import '../../data/repositories/conversation_repository.dart';
import '../../domain/models/message.dart';
import '../../domain/models/conversation.dart';
import '../../data/datasources/ollama_api_service.dart';

/// Provider for the conversation repository
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository(
    database: ref.watch(databaseServiceProvider),
  );
});

/// Provider for the database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = DatabaseService();
  service.init();
  return service;
});

/// Provider for all conversations
final conversationsProvider = Provider<List<Conversation>>((ref) {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getAllConversations();
});

/// Provider for messages in a specific conversation
final messagesProvider = Provider.family<List<Message>, String>((ref, conversationId) {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getMessages(conversationId);
});

/// Provider for the current active conversation
final currentConversationProvider = StateNotifierProvider<CurrentConversationNotifier, Conversation?>((ref) {
  return CurrentConversationNotifier(ref.watch(conversationRepositoryProvider));
});

class CurrentConversationNotifier extends StateNotifier<Conversation?> {
  final ConversationRepository _repository;

  CurrentConversationNotifier(this._repository) : super(null);

  void setConversation(Conversation? conversation) {
    state = conversation;
  }

  Future<void> createNewConversation({String? selectedModel}) async {
    final conversation = Conversation.create(selectedModel: selectedModel);
    await _repository.createConversation(conversation);
    state = conversation;
  }

  Future<void> deleteConversation(String id) async {
    await _repository.deleteConversation(id);
    if (state?.id == id) {
      state = null;
    }
  }
}

/// Provider for chat state and streaming
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(ollamaRepositoryProvider),
    ref.watch(conversationRepositoryProvider),
  );
});

class ChatState {
  final bool isLoading;
  final String? error;
  final String streamingContent;
  final bool isStreaming;

  ChatState({
    this.isLoading = false,
    this.error,
    this.streamingContent = '',
    this.isStreaming = false,
  });

  ChatState copyWith({
    bool? isLoading,
    String? error,
    String? streamingContent,
    bool? isStreaming,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      streamingContent: streamingContent ?? this.streamingContent,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final OllamaRepository _ollamaRepository;
  final ConversationRepository _conversationRepository;

  ChatNotifier(this._ollamaRepository, this._conversationRepository)
      : super(ChatState());

  /// Send a message and get streaming response
  Future<void> sendMessage({
    required String content,
    required String conversationId,
    required String model,
    double? temperature,
    int? contextLength,
  }) async {
    // Create and save user message
    final userMessage = Message.user(
      content: content,
      conversationId: conversationId,
    );
    await _conversationRepository.addMessage(userMessage);

    // Get conversation history
    final messages = _conversationRepository.getMessages(conversationId);

    // Update state
    state = state.copyWith(
      isLoading: true,
      error: null,
      streamingContent: '',
      isStreaming: true,
    );

    // Create assistant message placeholder
    final assistantMessage = Message.assistant(
      content: '',
      conversationId: conversationId,
    );

    try {
      final stream = _ollamaRepository.pullModel(model).isEmpty
          ? _ollamaRepository.chatStream(
              model: model,
              messages: messages,
              temperature: temperature,
              contextLength: contextLength,
            )
          : throw Exception('Model not available');

      final contentBuffer = StringBuffer();

      await for (final event in stream) {
        if (event.content != null) {
          contentBuffer.write(event.content);
          state = state.copyWith(
            streamingContent: contentBuffer.toString(),
          );

          // Update the assistant message incrementally
          assistantMessage.copyWith(
            content: contentBuffer.toString(),
          );
        }
      }

      // Save the complete assistant message
      final completeMessage = Message.assistant(
        content: contentBuffer.toString(),
        conversationId: conversationId,
      );
      await _conversationRepository.addMessage(completeMessage);

      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
        streamingContent: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Stop streaming (placeholder for future implementation)
  void stopStreaming() {
    state = state.copyWith(
      isLoading: false,
      isStreaming: false,
    );
  }
}
