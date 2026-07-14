import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/ai_provider_config.dart';

class KeyStorage {
  final _storage = const FlutterSecureStorage();

  static const _aiConfig = 'ai_config';

  // Legacy keys for migration (adjustment #9: kept forever)
  static const _legacyApiKey = 'api_key';
  static const _legacyAiProvider = 'ai_provider';
  static const _legacyAiModeEnabled = 'ai_mode_enabled';

  Future<void> saveAiConfig(AiProviderConfig config) async {
    await _storage.write(key: _aiConfig, value: jsonEncode(config.toMap()));
  }

  Future<AiProviderConfig> getAiConfig() async {
    final raw = await _storage.read(key: _aiConfig);
    if (raw != null) {
      try {
        return AiProviderConfig.fromMap(jsonDecode(raw));
      } catch (_) {}
    }

    // Migration from old keys (idempotent, never removed)
    final migrated = await _migrateLegacyKeys();
    await saveAiConfig(migrated);
    return migrated;
  }

  Future<AiProviderConfig> _migrateLegacyKeys() async {
    final apiKey = await _storage.read(key: _legacyApiKey);
    final provider = await _storage.read(key: _legacyAiProvider);
    final enabled = await _storage.read(key: _legacyAiModeEnabled);

    if (apiKey == null && provider == null && enabled == null) {
      return AiProviderConfig.defaults;
    }

    final isEnabled = enabled == 'true';
    final providerName = provider ?? 'OpenAI';
    final providerType = AiProviderType.values.firstWhere(
      (t) => t.name == providerName.toLowerCase(),
      orElse: () => AiProviderType.openai,
    );
    final preset = AiProviderPreset.byType(providerType) ?? AiProviderPreset.presets.first;

    final config = AiProviderConfig(
      type: providerType,
      displayName: preset.displayName,
      apiKey: apiKey ?? '',
      baseUrl: preset.defaultBaseUrl,
      model: preset.defaultModel,
      visionModel: preset.defaultVisionModel,
      enabled: isEnabled,
      supportsVision: true,
      format: ApiFormat.values.firstWhere(
        (f) => f.name == preset.format,
        orElse: () => ApiFormat.openai,
      ),
    );

    // Clean up old keys
    await _storage.delete(key: _legacyApiKey);
    await _storage.delete(key: _legacyAiProvider);
    await _storage.delete(key: _legacyAiModeEnabled);

    return config;
  }

  String maskKey(String key) {
    if (key.length < 4) return '\u2022\u2022\u2022\u2022';
    return '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022${key.substring(key.length - 4)}';
  }
}
