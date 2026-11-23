enum AiProviderType { openai, gemini, xai, groq, custom }

/// AI parsing configuration.
///
/// Deliberately minimal: the user picks a provider and pastes an API key. One
/// multimodal model handles everything (the card image + OCR text go in the same
/// request) — there is no separate "text" vs "vision" model. Base URL and API
/// shape are derived from the provider; only "Custom" exposes a URL field.
class AiProviderConfig {
  final bool enabled;
  final AiProviderType type;
  final String apiKey;

  /// Optional model override. Blank → the provider's default ([effectiveModel]).
  final String model;

  /// Only used when [type] is [AiProviderType.custom].
  final String customBaseUrl;

  const AiProviderConfig({
    this.enabled = false,
    this.type = AiProviderType.openai,
    this.apiKey = '',
    this.model = '',
    this.customBaseUrl = '',
  });

  static const defaults = AiProviderConfig();

  String get displayName => switch (type) {
        AiProviderType.openai => 'OpenAI',
        AiProviderType.gemini => 'Google Gemini',
        AiProviderType.xai => 'xAI (Grok)',
        AiProviderType.groq => 'Groq',
        AiProviderType.custom => 'Custom',
      };

  /// True when the provider speaks Google's `generateContent` API rather than
  /// the OpenAI `chat/completions` shape.
  bool get isGemini => type == AiProviderType.gemini;

  String get baseUrl => switch (type) {
        AiProviderType.openai => 'https://api.openai.com/v1',
        AiProviderType.gemini => 'https://generativelanguage.googleapis.com/v1beta',
        AiProviderType.xai => 'https://api.x.ai/v1',
        AiProviderType.groq => 'https://api.groq.com/openai/v1',
        AiProviderType.custom => customBaseUrl.trim(),
      };

  /// Sensible starting model per provider. These drift over time as providers
  /// retire models — the settings screen keeps the field editable so a stale
  /// default can be corrected without an app update.
  static String defaultModelFor(AiProviderType t) => switch (t) {
        AiProviderType.openai => 'gpt-5-mini',
        AiProviderType.gemini => 'gemini-2.5-flash',
        AiProviderType.xai => 'grok-4',
        AiProviderType.groq => 'qwen/qwen3.8-27b',
        AiProviderType.custom => '',
      };

  /// Tried in order if the chosen Groq model has been retired.
  static const groqFallbackModels = [
    'qwen/qwen3.8-27b',
    'meta-llama/llama-4-scout-17b-16e-instruct',
    'meta-llama/llama-4-maverick-17b-128e-instruct',
  ];

  /// The model id to actually send — the override if set, else the provider default.
  String get effectiveModel {
    final m = model.trim();
    return m.isNotEmpty ? m : defaultModelFor(type);
  }

  /// Whether this config has enough to make a request.
  bool get isUsable {
    if (apiKey.trim().isEmpty) return false;
    if (effectiveModel.isEmpty) return false;
    if (type == AiProviderType.custom) {
      final uri = Uri.tryParse(customBaseUrl.trim());
      return uri != null && uri.isAbsolute && uri.scheme == 'https';
    }
    return true;
  }

  AiProviderConfig copyWith({
    bool? enabled,
    AiProviderType? type,
    String? apiKey,
    String? model,
    String? customBaseUrl,
  }) {
    return AiProviderConfig(
      enabled: enabled ?? this.enabled,
      type: type ?? this.type,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      customBaseUrl: customBaseUrl ?? this.customBaseUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'type': type.name,
        'apiKey': apiKey,
        'model': model,
        'customBaseUrl': customBaseUrl,
      };

  // Model ids that older builds stored as *defaults* (not user choices). If a
  // migrated config carries one of these, treat it as "no override" so the
  // current provider default applies.
  static const _legacyDefaultModels = {
    'gpt-4o', 'gpt-4o-mini', 'grok-3', 'grok-3-mini', 'grok-2-vision-1212',
    'gemini-1.5-flash', 'gemini-1.5-pro', 'qwen/qwen3.6-27b',
    'meta-llama/llama-4-scout-17b-16e-instruct',
    'llama-3.2-11b-vision-preview', 'llama-3.2-90b-vision-preview',
  };

  factory AiProviderConfig.fromMap(Map<String, dynamic> map) {
    final rawModel = (map['model'] as String?)?.trim() ?? '';
    return AiProviderConfig(
      enabled: map['enabled'] == true,
      type: AiProviderType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => AiProviderType.openai,
      ),
      apiKey: (map['apiKey'] as String?) ?? '',
      model: _legacyDefaultModels.contains(rawModel) ? '' : rawModel,
      customBaseUrl: (map['customBaseUrl'] as String?) ??
          // migrate old configs that stored a full baseUrl
          ((map['type'] == 'custom' ? map['baseUrl'] as String? : null) ?? ''),
    );
  }
}
