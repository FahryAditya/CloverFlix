import 'dart:convert';
import 'package:http/http.dart' as http;

class MangaDexAPI {
  static const String _baseUrl = 'https://api.mangadex.org';

  static Future<List<dynamic>> searchManga(String query, {int limit = 20, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/manga?title=$query&limit=$limit&offset=$offset&includes[]=cover_art'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to search manga');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getTrendingManga({int limit = 20, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/manga?limit=$limit&offset=$offset&includes[]=cover_art&order[followedCount]=desc'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to get trending manga');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getMangaDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/manga/$id?includes[]=cover_art&includes[]=author&includes[]=artist'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to get manga detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getMangaChapters(String mangaId, {int limit = 100, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/manga/$mangaId/feed?limit=$limit&offset=$offset&order[chapter]=asc&translatedLanguage[]=en'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to get chapters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static String getCoverUrl(String mangaId, String fileName) {
    return 'https://uploads.mangadex.org/covers/$mangaId/$fileName';
  }
}