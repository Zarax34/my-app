import 'package:flutter/foundation.dart';
import '../../models/ollama_model.dart';
import '../datasources/ollama_api_service.dart';
import '../storage/local_storage_service.dart';

/// Repository for managing Ollama server connection and models
class OllamaRepository {
  final OllamaApiService _apiService;
  final LocalStorageService _localStorage;

  OllamaRepository({
    required OllamaApiService apiService,
    required LocalStorageService localStorage,
  })  : _apiService = apiService,
        _localStorage = localStorage;

  /// Get the saved server URL
  Future<String?> getServerUrl() async {
    return _localStorage.getServerUrl();
  }

  /// Save the server URL and initialize the API service
  Future<void> setServerUrl(String url) async {
    await _localStorage.setServerUrl(url);
    _apiService.initialize(url);
  }

  /// Test connection to the Ollama server
  Future<bool> testConnection() async {
    return _apiService.testConnection();
  }

  /// Get list of available models
  Future<List<OllamaModel>> getModels() async {
    return _apiService.getModels();
  }

  /// Pull a model from the registry
  Stream<PullProgressEvent> pullModel(String modelName) {
    return _apiService.pullModel(modelName);
  }

  /// Get the saved selected model
  Future<String?> getSelectedModel() async {
    return _localStorage.getSelectedModel();
  }

  /// Save the selected model
  Future<void> setSelectedModel(String model) async {
    await _localStorage.setSelectedModel(model);
  }

  /// Check if server is configured
  Future<bool> isServerConfigured() async {
    final url = await getServerUrl();
    return url != null && url.isNotEmpty;
  }

  /// Initialize API with saved URL
  Future<void> initializeFromStorage() async {
    final url = await getServerUrl();
    if (url != null && url.isNotEmpty) {
      _apiService.initialize(url);
    }
  }
}
