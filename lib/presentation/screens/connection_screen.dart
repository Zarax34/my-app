import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ollama_providers.dart';
import 'chat_screen.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final TextEditingController _urlController = TextEditingController(text: 'http://192.168.1.');
  bool _isTesting = false;
  String? _status;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isTesting = true;
      _status = null;
    });

    try {
      final notifier = ref.read(serverUrlProvider.notifier);
      await notifier.setServerUrl(url);

      setState(() {
        _status = 'Connected!';
        _isTesting = false;
      });

      // Navigate to chat
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedCol = isDark ? const Color(0xFF737373) : Colors.grey.shade600;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Text(
                'ollama',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect to your Ollama server',
                style: TextStyle(fontSize: 14, color: mutedCol),
              ),
              const SizedBox(height: 40),

              // URL input
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://192.168.1.100:11434',
                  prefixIcon: Icon(Icons.link, size: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Connect button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isTesting ? null : _connect,
                  child: _isTesting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Connect'),
                ),
              ),

              // Status
              if (_status != null) ...[
                const SizedBox(height: 16),
                Text(
                  _status!,
                  style: TextStyle(
                    fontSize: 13,
                    color: _status!.startsWith('Error') ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
