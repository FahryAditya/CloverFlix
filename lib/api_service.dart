import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'anime.dart';
import 'episode.dart';

class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'https://your-backend-api.com/api';
  
  // Get authorization header
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login with Google
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (e) {
      print('Error logging in: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get all anime
  Future<List<Anime>> getAnimeList({String? search}) async {
    try {
      final headers = await _getHeaders();
      final uri = search != null && search.isNotEmpty
          ? Uri.parse('$baseUrl/anime?search=$search')
          : Uri.parse('$baseUrl/anime');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Anime.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching anime: $e');
      return [];
    }
  }

  // Get episodes for specific anime
  Future<List<Episode>> getEpisodes(String animeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/episodes?anime_id=$animeId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Episode.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching episodes: $e');
      return [];
    }
  }

  // Save watch history/progress
  Future<bool> saveWatchHistory({
    required String animeId,
    required String episodeId,
    required int progress,
    required int duration,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/history'),
        headers: headers,
        body: jsonEncode({
          'anime_id': animeId,
          'episode_id': episodeId,
          'progress': progress,
          'duration': duration,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving watch history: $e');
      return false;
    }
  }

  // Get watch history
  Future<List<Map<String, dynamic>>> getWatchHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching watch history: $e');
      return [];
    }
  }

  // Get episode progress
  Future<int> getEpisodeProgress(String episodeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/history/progress?episode_id=$episodeId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['progress'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching episode progress: $e');
      return 0;
    }
  }
}