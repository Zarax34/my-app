import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../models/ollama_model.dart';
import '../../domain/models/message.dart';

/// Stream event for chat responses
class ChatStreamEvent {
  final String? content;
  final bool isDone;
  final String? model;
  final DateTime createdAt;

  ChatStreamEvent({
    this.content,
    this.isDone = false,
    this.model,
    required this.createdAt,
  });

  factory ChatStreamEvent.fromJson(Map<String, dynamic> json) {
    return ChatStreamEvent(
      content: json['message']?['content'],
      isDone: json['done'] == true,
      model: json['model'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

/// Progress event for model pulling
class PullProgressEvent {
  final String? status;
  final String? digest;
  final int? total;
  final int? completed;
  final double? progress;

  PullProgressEvent({
    this.status,
    this.digest,
    this.total,
    this.completed,
    this.progress,
  });

  factory PullProgressEvent.fromJson(Map<String, dynamic> json) {
    final total = json['total'];
    final completed = json['completed'];
    return PullProgressEvent(
      status: json['status'],
      digest: json['digest'],
      total: total,
      completed: completed,
      progress: total != null && completed != null
          ? completed / total
          : null,
    );
  }
}

/// Ollama API service for all backend communication
class OllamaApiService {
  late Dio _dio;
  String? _baseUrl;

  /// Initialize the API service with a base URL
  void initialize(String baseUrl) {
    // Remove trailing slash if present
    _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl!,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 0), // No timeout for streaming
    ));

    // Configure Dio to follow redirects and handle SSL
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  String get baseUrl => _baseUrl ?? '';

  /// Test connection to Ollama server
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/api/tags');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available models from the server
  Future<List<OllamaModel>> getModels() async {
    try {
      final response = await _dio.get('/api/tags');
      final modelsResponse = OllamaModelsResponse.fromJson(response.data);
      return modelsResponse.models;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Pull a model from the Ollama registry
  /// Returns a stream of progress events
  Stream<PullProgressEvent> pullModel(String modelName) async* {
    try {
      final response = await _dio.post(
        '/api/pull',
        data: {
          'name': modelName,
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 30),
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      final decoder = utf8.decoder;
      final lines = decoder.bind(stream).transform(const LineSplitter());

      await for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          yield PullProgressEvent.fromJson(json);
        } catch (e) {
          // Skip invalid JSON lines
          continue;
        }
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Send a chat message and receive streaming response
  /// Returns a stream of chat events
  Stream<ChatStreamEvent> chatStream({
    required String model,
    required List<Message> messages,
    double? temperature,
    int? contextLength,
  }) async* {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'model': model,
          'messages': messages.map((m) => m.toOllamaFormat()).toList(),
          'stream': true,
          if (temperature != null) 'options': {
            'temperature': temperature,
            if (contextLength != null) 'num_ctx': contextLength,
          },
        },
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 10),
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      final decoder = utf8.decoder;
      final lines = decoder.bind(stream).transform(const LineSplitter());

      await for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          yield ChatStreamEvent.fromJson(json);
        } catch (e) {
          // Skip invalid JSON lines
          continue;
        }
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Non-streaming chat (fallback)
  Future<Map<String, dynamic>> chat({
    required String model,
    required List<Message> messages,
    double? temperature,
    int? contextLength,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'model': model,
          'messages': messages.map((m) => m.toOllamaFormat()).toList(),
          'stream': false,
          if (temperature != null) 'options': {
            'temperature': temperature,
            if (contextLength != null) 'num_ctx': contextLength,
          },
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a model
  Future<void> deleteModel(String modelName) async {
    try {
      await _dio.delete('/api/delete', data: {'name': modelName});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Show model information
  Future<Map<String, dynamic>> showModel(String modelName) async {
    try {
      final response = await _dio.post('/api/show', data: {'name': modelName});
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and return user-friendly messages
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return OllamaException('Connection timed out. Please check your network.');
      case DioExceptionType.sendTimeout:
        return OllamaException('Request timed out. The server may be busy.');
      case DioExceptionType.receiveTimeout:
        return OllamaException('Response timed out. Please try again.');
      case DioExceptionType.badResponse:
        return OllamaException(
          'Server error: ${e.response?.statusCode ?? "Unknown"}',
        );
      case DioExceptionType.cancel:
        return OllamaException('Request was cancelled.');
      case DioExceptionType.connectionError:
        return OllamaException(
          'Cannot connect to server. Please check your URL and network connection.',
        );
      case DioExceptionType.unknown:
      default:
        return OllamaException('An unexpected error occurred: ${e.message}');
    }
  }
}

/// Custom exception for Ollama API errors
class OllamaException implements Exception {
  final String message;
  OllamaException(this.message);

  @override
  String toString() => message;
}
