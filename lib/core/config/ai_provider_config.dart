enum AiProviderType { openai, xai, gemini, custom }

enum ApiFormat { openai, gemini }

class AiProviderPreset {
  final AiProviderType type;
  final String displayName;
  final String defaultBaseUrl;
  final String defaultModel;
  final String defaultVisionModel;
  final String format;

  const AiProviderPreset({
    required this.type,
    required this.displayName,
    required this.defaultBaseUrl,
    required this.defaultModel,
    required this.defaultVisionModel,
    required this.format,
  });

  static const presets = [
    AiProviderPreset(
      type: AiProviderType.openai,
      displayName: 'OpenAI',
      defaultBaseUrl: 'https://api.openai.com/v1',
      defaultModel: 'gpt-4o-mini',
      defaultVisionModel: 'gpt-4o',
      format: 'openai',
    ),
    AiProviderPreset(
      type: AiProviderType.xai,
      displayName: 'xAI (Grok)',
      defaultBaseUrl: 'https://api.x.ai/v1',
      defaultModel: 'grok-3-mini',
      defaultVisionModel: 'grok-3',
      format: 'openai',
    ),
    AiProviderPreset(
      type: AiProviderType.gemini,
      displayName: 'Google Gemini',
      defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      defaultModel: 'gemini-2.5-flash',
      defaultVisionModel: 'gemini-2.5-flash',
      format: 'gemini',
    ),
  ];

  static AiProviderPreset? byType(AiProviderType type) {
    for (final p in presets) {
      if (p.type == type) return p;
    }
    return null;
  }
}

class AiProviderConfig {
  final AiProviderType type;
  final String displayName;
  final String apiKey;
  final String baseUrl;
  final String model;
  final String visionModel;
  final bool enabled;
  final bool supportsVision;
  final ApiFormat format;

  const AiProviderConfig({
    required this.type,
    required this.displayName,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    required this.visionModel,
    required this.enabled,
    required this.supportsVision,
    required this.format,
  });

  static const defaults = AiProviderConfig(
    type: AiProviderType.openai,
    displayName: 'OpenAI',
    apiKey: '',
    baseUrl: 'https://api.openai.com/v1',
    model: 'gpt-4o-mini',
    visionModel: 'gpt-4o',
    enabled: false,
    supportsVision: true,
    format: ApiFormat.openai,
  );

  AiProviderConfig copyWith({
    AiProviderType? type,
    String? displayName,
    String? apiKey,
    String? baseUrl,
    String? model,
    String? visionModel,
    bool? enabled,
    bool? supportsVision,
    ApiFormat? format,
  }) {
    return AiProviderConfig(
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      visionModel: visionModel ?? this.visionModel,
      enabled: enabled ?? this.enabled,
      supportsVision: supportsVision ?? this.supportsVision,
      format: format ?? this.format,
    );
  }

  AiProviderConfig mergeWithPreset(AiProviderType newType, {String? currentBaseUrl, String? currentModel, String? currentVisionModel}) {
    final preset = AiProviderPreset.byType(newType);
    if (preset == null) return this;

    final isCustom = newType == AiProviderType.custom;

    bool wasPreset(String? current, String presetDefault) {
      if (current == null || current.isEmpty) return true;
      for (final p in AiProviderPreset.presets) {
        if (current == p.defaultBaseUrl || current == p.defaultModel || current == p.defaultVisionModel) return true;
      }
      return false;
    }

    return AiProviderConfig(
      type: newType,
      displayName: isCustom ? 'Custom' : preset.displayName,
      apiKey: apiKey,
      baseUrl: wasPreset(currentBaseUrl ?? baseUrl, '') ? (isCustom ? '' : preset.defaultBaseUrl) : baseUrl,
      model: wasPreset(currentModel ?? model, '') ? (isCustom ? '' : preset.defaultModel) : model,
      visionModel: wasPreset(currentVisionModel ?? visionModel, '') ? (isCustom ? '' : preset.defaultVisionModel) : visionModel,
      enabled: enabled,
      supportsVision: isCustom ? supportsVision : true,
      format: isCustom ? format : ApiFormat.values.firstWhere((f) => f.name == preset.format),
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'displayName': displayName,
    'apiKey': apiKey,
    'baseUrl': baseUrl,
    'model': model,
    'visionModel': visionModel,
    'enabled': enabled,
    'supportsVision': supportsVision,
    'format': format.name,
  };

  factory AiProviderConfig.fromMap(Map<String, dynamic> map) {
    return AiProviderConfig(
      type: AiProviderType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => AiProviderType.openai,
      ),
      displayName: map['displayName'] ?? 'OpenAI',
      apiKey: map['apiKey'] ?? '',
      baseUrl: map['baseUrl'] ?? '',
      model: map['model'] ?? '',
      visionModel: map['visionModel'] ?? '',
      enabled: map['enabled'] ?? false,
      supportsVision: map['supportsVision'] ?? false,
      format: ApiFormat.values.firstWhere(
        (f) => f.name == map['format'],
        orElse: () => ApiFormat.openai,
      ),
    );
  }

  String get effectiveVisionModel => visionModel.isNotEmpty ? visionModel : model;
}
