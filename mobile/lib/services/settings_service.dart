import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyApiBaseUrl = 'api_base_url_v2';
  static const _keyStreamQuality = 'stream_quality';
  static const _keyThemeMode = 'theme_mode';
  static const _keyAutoPlay = 'auto_play';
  static const _keyCacheEnabled = 'cache_enabled';

  static const String defaultApiUrl = 'http://10.99.189.95:8000';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  // API base URL
  String get apiBaseUrl => _prefs.getString(_keyApiBaseUrl) ?? defaultApiUrl;
  Future<void> setApiBaseUrl(String url) => _prefs.setString(_keyApiBaseUrl, url);

  // Stream quality: 'low' | 'high'
  String get streamQuality => _prefs.getString(_keyStreamQuality) ?? 'high';
  Future<void> setStreamQuality(String q) => _prefs.setString(_keyStreamQuality, q);

  // Theme: 'dark' | 'light' | 'system'
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'dark';
  Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  // Auto-play next track
  bool get autoPlay => _prefs.getBool(_keyAutoPlay) ?? true;
  Future<void> setAutoPlay(bool v) => _prefs.setBool(_keyAutoPlay, v);

  // Offline cache
  bool get cacheEnabled => _prefs.getBool(_keyCacheEnabled) ?? false;
  Future<void> setCacheEnabled(bool v) => _prefs.setBool(_keyCacheEnabled, v);
}
