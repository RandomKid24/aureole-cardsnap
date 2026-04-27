import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorage {
  final _storage = const FlutterSecureStorage();

  static const _apiKey = 'api_key';
  static const _aiProvider = 'ai_provider';
  static const _aiModeEnabled = 'ai_mode_enabled';

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: _apiKey, value: key);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKey);
  }

  Future<void> saveAiProvider(String provider) async {
    await _storage.write(key: _aiProvider, value: provider);
  }

  Future<String> getAiProvider() async {
    return await _storage.read(key: _aiProvider) ?? 'OpenAI';
  }

  Future<void> setAiModeEnabled(bool enabled) async {
    await _storage.write(key: _aiModeEnabled, value: enabled.toString());
  }

  Future<bool> isAiModeEnabled() async {
    final value = await _storage.read(key: _aiModeEnabled);
    return value == 'true';
  }

  String maskKey(String key) {
    if (key.length < 4) return '••••';
    return '••••••••${key.substring(key.length - 4)}';
  }
}
