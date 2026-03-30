import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ollama_providers.dart';

/// Dialog for pulling a new model from Ollama registry
class PullModelDialog extends ConsumerStatefulWidget {
  const PullModelDialog({super.key});

  @override
  ConsumerState<PullModelDialog> createState() => _PullModelDialogState();
}

class _PullModelDialogState extends ConsumerState<PullModelDialog> {
  final _controller = TextEditingController();
  bool _isPulling = false;
  double? _progress;
  String? _status;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pullModel() async {
    final modelName = _controller.text.trim();
    if (modelName.isEmpty) return;

    setState(() {
      _isPulling = true;
      _error = null;
    });

    try {
      final stream = ref.read(pullModelProvider.notifier).pullModel(modelName);

      await for (final event in stream) {
        if (mounted) {
          setState(() {
            _progress = event.progress;
            _status = event.status;
          });
        }
      }

      if (mounted) {
        setState(() {
          _isPulling = false;
          _progress = 1.0;
          _status = 'Complete!';
        });

        // Refresh models list
        ref.read(modelsProvider.notifier).refresh();

        // Show success and close after delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Model "$modelName" pulled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPulling = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pull Model'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the model name to pull from Ollama registry.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Model Name',
                hintText: 'e.g., llama3.2, mistral, gemma:2b',
                prefixIcon: Icon(Icons.download),
              ),
              enabled: !_isPulling,
              onSubmitted: (_) => _pullModel(),
            ),
            const SizedBox(height: 8),
            Text(
              'Popular models: llama3.2, mistral, gemma:2b, phi3, qwen2.5',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            if (_isPulling || _progress != null) ...[
              const SizedBox(height: 24),
              if (_status != null)
                Text(
                  _status!,
                  style: const TextStyle(fontSize: 13),
                ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
              if (_progress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${(_progress! * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isPulling)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        if (!_isPulling)
          ElevatedButton(
            onPressed: _pullModel,
            child: const Text('Pull'),
          ),
        if (_isPulling)
          TextButton(
            onPressed: () {
              ref.read(pullModelProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
      ],
    );
  }
}
