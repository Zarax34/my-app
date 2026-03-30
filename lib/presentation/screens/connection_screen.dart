import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/ollama_providers.dart';
import '../providers/settings_providers.dart';
import 'chat_screen.dart';

/// Server connection and onboarding screen
class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isTesting = false;
  String? _errorMessage;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final url = await ref.read(serverUrlProvider.notifier).getServerUrl();
    if (url != null && url.isNotEmpty) {
      _urlController.text = url;
      // Auto-test connection if URL exists
      _testConnection();
    }
  }

  Future<void> _testConnection() async {
    if (_urlController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a server URL';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(serverUrlProvider.notifier).setServerUrl(_urlController.text);
      final success = await ref.read(serverUrlProvider.notifier).testConnection();

      if (success && mounted) {
        setState(() {
          _isConnected = true;
          _isTesting = false;
        });
        // Show success and navigate to chat
        _showSuccessAndNavigate();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Cannot connect to server. Please check the URL and your network.';
          _isTesting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isTesting = false;
        });
      }
    }
  }

  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connected successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate to chat screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(darkModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo and Title
              _buildHeader(isDark),
              const Spacer(),
              // Connection Form
              _buildForm(),
              const SizedBox(height: 24),
              // Test Button
              _buildTestButton(),
              const SizedBox(height: 16),
              // Error Message
              if (_errorMessage != null) _buildErrorMessage(),
              const SizedBox(height: 32),
              // Help Text
              _buildHelpText(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
                isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5))
                    .withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Ollama Mobile Studio',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect to your local Ollama server',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Server URL',
              hintText: 'http://192.168.1.100:11434',
              prefixIcon: Icon(Icons.link),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a server URL';
              }
              if (!value.startsWith('http://') && !value.startsWith('https://')) {
                return 'URL must start with http:// or https://';
              }
              return null;
            },
            onFieldSubmitted: (_) => _testConnection(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton() {
    return ElevatedButton(
      onPressed: _isTesting ? null : _testConnection,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isTesting) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(_isConnected ? 'Connected' : 'Test Connection'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpText() {
    final isDark = ref.watch(darkModeProvider);
    return Column(
      children: [
        const Divider(),
        Text(
          'How to find your server URL:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildHelpStep('1. Open terminal on your computer'),
        _buildHelpStep('2. Run: ipconfig (Windows) or ifconfig (Mac/Linux)'),
        _buildHelpStep('3. Find your local IP (e.g., 192.168.1.x)'),
        _buildHelpStep('4. Enter: http://YOUR_IP:11434'),
        const SizedBox(height: 16),
        Text(
          'Make sure Ollama is running and your firewall allows connections.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black54,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHelpStep(String text) {
    final isDark = ref.watch(darkModeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white60 : Colors.black60,
        ),
      ),
    );
  }
}
