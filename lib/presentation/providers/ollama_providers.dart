import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/ollama_api_service.dart';
import '../../data/repositories/ollama_repository.dart';
import '../../data/storage/local_storage_service.dart';
import '../../models/ollama_model.dart';

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
    state = await _repository.getServerUrl();
    if (state != null && state!.isNotEmpty) {
      _repository.initializeFromStorage();
    }
  }

  Future<void> setServerUrl(String url) async {
    state = url;
    await _repository.setServerUrl(url);
  }

  Future<bool> testConnection() async {
    return _repository.testConnection();
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

  Future<void> pullModel(String modelName) async {
    // This is handled separately via the pullModelProvider
  }
}

/// Provider for model pulling progress
final pullModelProvider = StateNotifierProvider<PullModelNotifier, PullModelState>((ref) {
  return PullModelNotifier(ref.watch(ollamaRepositoryProvider));
});

class PullModelState {
  final bool isLoading;
  final double? progress;
  final String? status;
  final String? error;

  PullModelState({
    this.isLoading = false,
    this.progress,
    this.status,
    this.error,
  });

  PullModelState copyWith({
    bool? isLoading,
    double? progress,
    String? status,
    String? error,
  }) {
    return PullModelState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class PullModelNotifier extends StateNotifier<PullModelState> {
  final OllamaRepository _repository;

  PullModelNotifier(this._repository) : super(PullModelState());

  Stream<PullProgressEvent> pullModel(String modelName) {
    return _repository.pullModel(modelName);
  }

  void reset() {
    state = PullModelState();
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
