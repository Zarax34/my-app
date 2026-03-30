/// Model information from Ollama API
class OllamaModel {
  final String name;
  final String model;
  final String? modifiedAt;
  final OllamaModelDetails? details;

  OllamaModel({
    required this.name,
    required this.model,
    this.modifiedAt,
    this.details,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      modifiedAt: json['modified_at'],
      details: json['details'] != null
          ? OllamaModelDetails.fromJson(json['details'])
          : null,
    );
  }

  String get displayName {
    // Remove the ":latest" or version tag for cleaner display
    final parts = name.split(':');
    return parts.first;
  }

  String get version {
    final parts = name.split(':');
    return parts.length > 1 ? parts.sublist(1).join(':') : 'latest';
  }
}

class OllamaModelDetails {
  final String? parentModel;
  final String? format;
  final String? family;
  final List<String>? families;
  final String? parameterSize;
  final String? quantizationLevel;

  OllamaModelDetails({
    this.parentModel,
    this.format,
    this.family,
    this.families,
    this.parameterSize,
    this.quantizationLevel,
  });

  factory OllamaModelDetails.fromJson(Map<String, dynamic> json) {
    return OllamaModelDetails(
      parentModel: json['parent_model'],
      format: json['format'],
      family: json['family'],
      families: json['families'] != null
          ? List<String>.from(json['families'])
          : null,
      parameterSize: json['parameter_size'],
      quantizationLevel: json['quantization_level'],
    );
  }
}

/// Response from /api/tags endpoint
class OllamaModelsResponse {
  final List<OllamaModel> models;

  OllamaModelsResponse({required this.models});

  factory OllamaModelsResponse.fromJson(Map<String, dynamic> json) {
    final modelsJson = json['models'] as List? ?? [];
    return OllamaModelsResponse(
      models: modelsJson
          .map((model) => OllamaModel.fromJson(model as Map<String, dynamic>))
          .toList(),
    );
  }
}
