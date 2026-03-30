import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../domain/models/message.dart';
import '../theme/app_theme.dart';

/// Chat message bubble widget with markdown support
class ChatMessageBubble extends StatelessWidget {
  final Message? message;
  final String? streamingContent;
  final bool isLast;
  final bool isStreaming;

  const ChatMessageBubble({
    super.key,
    this.message,
    this.streamingContent,
    this.isLast = false,
    this.isStreaming = false,
  }) : assert(message != null || streamingContent != null);

  /// Constructor for streaming messages
  factory ChatMessageBubble.streaming({
    required String content,
  }) {
    return ChatMessageBubble(
      streamingContent: content,
      isStreaming: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message?.role == MessageRole.user;
    final content = message?.content ?? streamingContent ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for assistant
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppTheme.darkPrimary,
              radius: 16,
              child: const Icon(
                Icons.smart_toy,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Message bubble
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showCopyOptions(context, content),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppTheme.darkUserBubble
                      : AppTheme.darkAssistantBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isStreaming) ...[
                      _buildStreamingContent(content),
                    ] else ...[
                      _buildMarkdownContent(content),
                    ],
                    // Timestamp
                    if (!isUser && !isStreaming) ...[
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(message!.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Avatar for user
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.darkSecondary,
              radius: 16,
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(String content) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.5,
        ),
        code: TextStyle(
          color: Colors.amber.shade300,
          backgroundColor: Colors.black38,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(8),
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        em: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.white,
        ),
        h1: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        h2: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        h3: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        listBullet: const TextStyle(
          color: Colors.white,
        ),
        listBulletPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildStreamingContent(String content) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.5,
        ),
        code: TextStyle(
          color: Colors.amber.shade300,
          backgroundColor: Colors.black38,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(8),
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showCopyOptions(BuildContext context, String content) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy to clipboard'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
