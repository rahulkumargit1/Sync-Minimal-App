import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';
import '../models/playlist.dart';
import 'settings_service.dart';

class ApiService {
  final SettingsService _settings;

  ApiService(this._settings);

  String get _base => _settings.apiBaseUrl.replaceAll(RegExp(r'/$'), '');

  Future<List<Track>> getTracks({int limit = 50, int offset = 0, String? genre}) async {
    var uri = Uri.parse('$_base/tracks').replace(queryParameters: {
      'limit': '$limit',
      'offset': '$offset',
      if (genre != null) 'genre': genre,
    });
    
    http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 3));
    } catch (_) {
      // If connection fails, try auto-detecting the new IP from S3
      final ok = await checkHealth();
      if (!ok) throw Exception('Server unreachable. Could not auto-detect IP.');
      
      // Retry with the new _base
      uri = Uri.parse('$_base/tracks').replace(queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
        if (genre != null) 'genre': genre,
      });
      response = await http.get(uri).timeout(const Duration(seconds: 5));
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => Track.fromJson(j)).toList();
    }
    throw Exception('Failed to load tracks (${response.statusCode})');
  }

  Future<List<String>> getGenres() async {
    final response = await http
        .get(Uri.parse('$_base/genres'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load genres (${response.statusCode})');
  }

  Future<List<Playlist>> getPlaylists() async {
    final response = await http
        .get(Uri.parse('$_base/playlists'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => Playlist.fromJson(j)).toList();
    }
    throw Exception('Failed to load playlists (${response.statusCode})');
  }

  Future<bool> _autoDetectServer() async {
    try {
      final s3Response = await http.get(Uri.parse('https://raw.githubusercontent.com/rahulkumargit1/Sync-Minimal-App/main/api/server.json'))
          .timeout(const Duration(seconds: 5));
      if (s3Response.statusCode == 200) {
        final data = jsonDecode(s3Response.body);
        final url = data['url'];
        if (url != null && url is String && url.isNotEmpty) {
          await _settings.setApiBaseUrl(url);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) return true;
    } catch (_) {}
    
    // Auto-detect from S3 fallback
    final detected = await _autoDetectServer();
    if (detected) {
      // Re-check with new URL
      try {
        final response = await http
            .get(Uri.parse('$_base/health'))
            .timeout(const Duration(seconds: 3));
        return response.statusCode == 200;
      } catch (_) {}
    }
    return false;
  }
}

