import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ollama_providers.dart';
import '../../domain/models/message.dart';
import '../../domain/models/conversation.dart';

/// Provider for current messages (simplified - no database dependency)
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
  return MessagesNotifier();
});

class MessagesNotifier extends StateNotifier<List<Message>> {
  MessagesNotifier() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }

  void clear() {
    state = [];
  }
}

/// Provider for chat streaming state
final chatStateProvider = StateNotifierProvider<ChatNotifier, ChatStreamingState>((ref) {
  return ChatNotifier(ref.watch(ollamaRepositoryProvider));
});

class ChatStreamingState {
  final bool isLoading;
  final String? error;
  final String streamingContent;
  final bool isStreaming;

  ChatStreamingState({
    this.isLoading = false,
    this.error,
    this.streamingContent = '',
    this.isStreaming = false,
  });

  ChatStreamingState copyWith({
    bool? isLoading,
    String? error,
    String? streamingContent,
    bool? isStreaming,
  }) {
    return ChatStreamingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      streamingContent: streamingContent ?? this.streamingContent,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatStreamingState> {
  final dynamic _repository;

  ChatNotifier(this._repository) : super(ChatStreamingState());

  Future<void> sendMessage({
    required String content,
    required String model,
    double? temperature,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      streamingContent: '',
      isStreaming: true,
    );

    try {
      // Simplified: just get response
      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
