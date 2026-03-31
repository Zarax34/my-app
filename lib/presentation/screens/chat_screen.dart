import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/ollama_providers.dart';
import '../providers/chat_providers.dart';
import '../theme/app_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final model = ref.read(selectedModelProvider);

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
    });
    _controller.clear();
    _scrollToBottom();

    // Get response from Ollama
    final repo = ref.read(ollamaRepositoryProvider);

    try {
      final response = await repo.chat(
        model: model ?? 'llama3.2',
        messages: _messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
      );

      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: response));
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: 'Error: $e'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverUrl = ref.watch(serverUrlProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedCol = isDark ? const Color(0xFF737373) : Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(serverUrl ?? 'Ollama', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 18, color: mutedCol),
            onPressed: () {
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Model selector
          _modelSelector(),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'How can I help you today?',
                      style: GoogleFonts.inter(fontSize: 18, color: mutedCol),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final msg = _messages[i];
                      final isUser = msg.role == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUser ? 'You' : 'Assistant',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: mutedCol,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              msg.content,
                              style: GoogleFonts.inter(fontSize: 14, height: 1.6),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Input
          _inputBar(isDark, mutedCol),
        ],
      ),
    );
  }

  Widget _modelSelector() {
    final modelsAsync = ref.watch(modelsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: modelsAsync.when(
        data: (models) => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: ref.watch(selectedModelProvider),
            hint: Text('Select model', style: GoogleFonts.inter(fontSize: 13)),
            isDense: true,
            items: models.map((m) => DropdownMenuItem(
              value: m.name,
              child: Text(m.name, style: GoogleFonts.inter(fontSize: 13)),
            )).toList(),
            onChanged: (v) {
              if (v != null) ref.read(selectedModelProvider.notifier).setSelectedModel(v);
            },
          ),
        ),
        loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Text('Error loading models', style: GoogleFonts.inter(fontSize: 12, color: Colors.red)),
      ),
    );
  }

  Widget _inputBar(bool isDark, Color mutedCol) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171717) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF262626) : Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Send a message',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 6),
                child: IconButton(
                  icon: Icon(Icons.arrow_upward, size: 18),
                  onPressed: _send,
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF262626) : Colors.grey.shade200,
                    minimumSize: const Size(28, 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  _ChatMessage({required this.role, required this.content});
}
