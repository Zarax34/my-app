import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';
import '../providers/ollama_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/model_selector.dart';
import 'settings_screen.dart';
import 'conversations_screen.dart';

/// Main chat screen with conversation history
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _ensureCurrentConversation();
  }

  Future<void> _ensureCurrentConversation() async {
    final current = ref.read(currentConversationProvider);
    if (current == null) {
      final selectedModel = await ref.read(selectedModelProvider.notifier).getSelectedModel();
      await ref.read(currentConversationProvider.notifier).createNewConversation(
        selectedModel: selectedModel,
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 200) {
      if (!_showScrollButton) {
        setState(() => _showScrollButton = true);
      }
    } else {
      if (_showScrollButton) {
        setState(() => _showScrollButton = false);
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentConversation = ref.read(currentConversationProvider);
    if (currentConversation == null) return;

    final selectedModel = ref.read(selectedModelProvider);
    if (selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a model first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final temperature = ref.read(temperatureProvider);
    final contextLength = ref.read(contextLengthProvider);

    // Clear input
    _messageController.clear();

    // Send message
    await ref.read(chatProvider.notifier).sendMessage(
      content: content,
      conversationId: currentConversation.id,
      model: selectedModel,
      temperature: temperature,
      contextLength: contextLength,
    );

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentConversation = ref.watch(currentConversationProvider);
    final chatState = ref.watch(chatProvider);
    final isDark = ref.watch(darkModeProvider);

    // Get messages for current conversation
    final messages = currentConversation != null
        ? ref.watch(messagesProvider(currentConversation.id))
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ollama Mobile Studio'),
        actions: [
          // Model Selector
          const ModelSelectorDropdown(),
          // Conversations button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Conversation History',
            onPressed: () => _openConversations(),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _openSettings(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: messages.isEmpty && !chatState.isLoading
                ? _buildEmptyState(isDark)
                : _buildMessagesList(messages, chatState, isDark),
          ),
          // Scroll to bottom button
          if (_showScrollButton)
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'scrollToBottom',
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward),
              ),
            ),
          // Input area
          _buildInputArea(chatState),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a model and send a message',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(
    List messages,
    ChatState chatState,
    bool isDark,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length + (chatState.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < messages.length) {
          final message = messages[index];
          return ChatMessageBubble(
            message: message,
            isLast: index == messages.length - 1,
          );
        } else {
          // Streaming message
          return ChatMessageBubble.streaming(
            content: chatState.streamingContent,
          );
        }
      },
    );
  }

  Widget _buildInputArea(ChatState chatState) {
    final isDark = ref.watch(darkModeProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !chatState.isLoading,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Send button
            Container(
              decoration: BoxDecoration(
                gradient: chatState.isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF10B981)],
                      ),
                color: chatState.isLoading ? Colors.grey : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: chatState.isLoading ? null : _sendMessage,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: chatState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openConversations() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ConversationsScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}

/// Wrapper screen with drawer for navigation
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: _buildDrawer(context, ref),
      body: const MainScreen(),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    final conversations = ref.watch(conversationsProvider);

    return Drawer(
      child: Column(
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
                  isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.chat_bubble, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Ollama Mobile Studio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${conversations.length} conversations',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // New chat button
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('New Conversation'),
            onTap: () {
              Navigator.pop(context);
              ref.read(currentConversationProvider.notifier).createNewConversation();
            },
          ),
          const Divider(),
          // Conversations list
          Expanded(
            child: conversations.isEmpty
                ? const Center(
                    child: Text('No conversations yet'),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(
                          conversation.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatDate(conversation.updatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(currentConversationProvider.notifier).setConversation(conversation);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _deleteConversation(context, ref, conversation.id),
                        ),
                      );
                    },
                  ),
          ),
          // Settings button at bottom
          Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _deleteConversation(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(currentConversationProvider.notifier).deleteConversation(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
