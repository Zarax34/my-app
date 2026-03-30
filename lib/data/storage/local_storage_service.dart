import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for app preferences
class LocalStorageService {
  static const String _serverUrlKey = 'ollama_server_url';
  static const String _selectedModelKey = 'selected_model';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _temperatureKey = 'temperature';
  static const String _contextLengthKey = 'context_length';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Server URL
  Future<String?> getServerUrl() async {
    await _ensureInit();
    return _prefs?.getString(_serverUrlKey);
  }

  Future<void> setServerUrl(String url) async {
    await _ensureInit();
    await _prefs?.setString(_serverUrlKey, url);
  }

  // Selected Model
  Future<String?> getSelectedModel() async {
    await _ensureInit();
    return _prefs?.getString(_selectedModelKey);
  }

  Future<void> setSelectedModel(String model) async {
    await _ensureInit();
    await _prefs?.setString(_selectedModelKey, model);
  }

  // Dark Mode
  Future<bool> isDarkModeEnabled() async {
    await _ensureInit();
    return _prefs?.getBool(_darkModeKey) ?? true; // Default to dark mode
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    await _ensureInit();
    await _prefs?.setBool(_darkModeKey, enabled);
  }

  // Temperature
  Future<double> getTemperature() async {
    await _ensureInit();
    return _prefs?.getDouble(_temperatureKey) ?? 0.7;
  }

  Future<void> setTemperature(double temp) async {
    await _ensureInit();
    await _prefs?.setDouble(_temperatureKey, temp);
  }

  // Context Length
  Future<int> getContextLength() async {
    await _ensureInit();
    return _prefs?.getInt(_contextLengthKey) ?? 4096;
  }

  Future<void> setContextLength(int length) async {
    await _ensureInit();
    await _prefs?.setInt(_contextLengthKey, length);
  }

  // Clear all settings
  Future<void> clearAll() async {
    await _ensureInit();
    await _prefs?.clear();
  }

  Future<void> _ensureInit() async {
    if (_prefs == null) {
      await init();
    }
  }
}
