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
    final uri = Uri.parse('$_base/tracks').replace(queryParameters: {
      'limit': '$limit',
      'offset': '$offset',
      if (genre != null) 'genre': genre,
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
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

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
