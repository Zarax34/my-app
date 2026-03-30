import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ollama_providers.dart';
import 'pull_model_dialog.dart';

/// Model selector dropdown widget
class ModelSelectorDropdown extends ConsumerWidget {
  const ModelSelectorDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(modelsProvider);
    final selectedModel = ref.watch(selectedModelProvider);

    return PopupMenuButton<String>(
      tooltip: 'Select Model',
      icon: const Icon(Icons.memory, size: 24),
      itemBuilder: (context) {
        return [
          // Models list
          if (modelsAsync.isLoading)
            const PopupMenuItem(
              enabled: false,
              child: SizedBox(
                width: 200,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (modelsAsync.hasError)
            PopupMenuItem(
              enabled: false,
              child: Row(
                children: [
                  const Icon(Icons.error, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Error loading models',
                    style: TextStyle(color: Colors.red.shade300),
                  ),
                ],
              ),
            )
          else if (modelsAsync.hasValue && modelsAsync.value!.isEmpty)
            const PopupMenuItem(
              enabled: false,
              child: Text('No models available'),
            )
          else if (modelsAsync.hasValue)
            ...modelsAsync.value!.map((model) {
              final isSelected = model.name == selectedModel;
              return PopupMenuItem<String>(
                value: model.name,
                child: Row(
                  children: [
                    if (isSelected)
                      const Icon(Icons.check, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.displayName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (model.details?.parameterSize != null)
                            Text(
                              model.details!.parameterSize!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          
          const PopupMenuDivider(),
          
          // Pull model option
          const PopupMenuItem<String>(
            value: '__pull__',
            child: Row(
              children: [
                Icon(Icons.download, size: 20),
                SizedBox(width: 8),
                Text('Pull New Model'),
              ],
            ),
          ),
          
          // Refresh option
          PopupMenuItem(
            onTap: () => ref.read(modelsProvider.notifier).refresh(),
            child: const Row(
              children: [
                Icon(Icons.refresh, size: 20),
                SizedBox(width: 8),
                Text('Refresh'),
              ],
            ),
          ),
        ];
      },
      onSelected: (value) async {
        if (value == '__pull__') {
          _showPullModelDialog(context, ref);
        } else {
          await ref.read(selectedModelProvider.notifier).setSelectedModel(value);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected model: $value'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (modelsAsync.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.memory, size: 20),
            const SizedBox(width: 4),
            Text(
              _getDisplayName(selectedModel),
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(String? model) {
    if (model == null) return 'Select Model';
    final parts = model.split(':');
    return parts.first;
  }

  void _showPullModelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => PullModelDialog(),
    );
  }
}
