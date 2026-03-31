import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/ollama_api_service.dart';
import '../../data/repositories/ollama_repository.dart';
import '../../data/storage/local_storage_service.dart';
import '../../models/ollama_model.dart';
import 'settings_providers.dart';

/// Provider for the Ollama API service
final ollamaApiServiceProvider = Provider<OllamaApiService>((ref) {
  return OllamaApiService();
});

/// Provider for the Ollama repository
final ollamaRepositoryProvider = Provider<OllamaRepository>((ref) {
  return OllamaRepository(
    apiService: ref.watch(ollamaApiServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

/// Provider for server URL state
final serverUrlProvider = StateNotifierProvider<ServerUrlNotifier, String?>((ref) {
  return ServerUrlNotifier(ref.watch(ollamaRepositoryProvider));
});

class ServerUrlNotifier extends StateNotifier<String?> {
  final OllamaRepository _repository;

  ServerUrlNotifier(this._repository) : super(null) {
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final url = await _repository.getServerUrl();
    if (url != null && url.isNotEmpty) {
      state = url;
    }
  }

  Future<void> setServerUrl(String url) async {
    state = url;
    await _repository.setServerUrl(url);
  }
}

/// Provider for available models
final modelsProvider = StateNotifierProvider<ModelsNotifier, AsyncValue<List<OllamaModel>>>((ref) {
  return ModelsNotifier(ref.watch(ollamaRepositoryProvider));
});

class ModelsNotifier extends StateNotifier<AsyncValue<List<OllamaModel>>> {
  final OllamaRepository _repository;

  ModelsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadModels();
  }

  Future<void> _loadModels() async {
    state = const AsyncValue.loading();
    try {
      final models = await _repository.getModels();
      state = AsyncValue.data(models);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadModels();
  }
}

/// Provider for selected model
final selectedModelProvider = StateNotifierProvider<SelectedModelNotifier, String?>((ref) {
  return SelectedModelNotifier(ref.watch(ollamaRepositoryProvider));
});

class SelectedModelNotifier extends StateNotifier<String?> {
  final OllamaRepository _repository;

  SelectedModelNotifier(this._repository) : super(null) {
    _loadSelectedModel();
  }

  Future<void> _loadSelectedModel() async {
    state = await _repository.getSelectedModel();
  }

  Future<void> setSelectedModel(String model) async {
    state = model;
    await _repository.setSelectedModel(model);
  }
}
