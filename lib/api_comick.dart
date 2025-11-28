import 'dart:convert';
import 'package:http/http.dart' as http;

class ComickAPI {
  static const String _baseUrl = 'https://api.comick.fun';

  static Future<List<dynamic>> getTrendingManhwa({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1.0/search?page=$page&limit=$limit&order=hot'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      } else {
        throw Exception('Failed to get trending manhwa');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getComicDetail(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/comic/$slug'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['comic'] ?? {};
      } else {
        throw Exception('Failed to get comic detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getComicChapters(String slug, {int page = 1, int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/comic/$slug/chapters?page=$page&limit=$limit&order=asc'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['chapters'] ?? [];
      } else {
        throw Exception('Failed to get chapters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> searchManhwa(String query, {int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1.0/search?q=$query&page=$page&limit=$limit'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      } else {
        throw Exception('Failed to search manhwa');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static String getCoverUrl(String coverUrl) {
    if (coverUrl.startsWith('http')) {
      return coverUrl;
    }
    return 'https://meo.comick.pictures/$coverUrl';
  }
}