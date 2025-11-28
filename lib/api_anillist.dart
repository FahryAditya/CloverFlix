import 'dart:convert';
import 'package:http/http.dart' as http;

class AniListAPI {
  static const String _baseUrl = 'https://graphql.anilist.co';

  static Future<Map<String, dynamic>> fetchAniList(String query, [Map<String, dynamic>? variables]) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'variables': variables ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<dynamic>> getTrendingAnime({int page = 1, int perPage = 20}) async {
    const query = '''
      query (\$page: Int, \$perPage: Int) {
        Page(page: \$page, perPage: \$perPage) {
          media(type: ANIME, sort: TRENDING_DESC) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              large
              extraLarge
            }
            bannerImage
            averageScore
            genres
            format
            episodes
            status
            season
            seasonYear
          }
        }
      }
    ''';

    final result = await fetchAniList(query, {'page': page, 'perPage': perPage});
    return result['data']['Page']['media'] ?? [];
  }

  static Future<List<dynamic>> getPopularAnime({int page = 1, int perPage = 20}) async {
    const query = '''
      query (\$page: Int, \$perPage: Int) {
        Page(page: \$page, perPage: \$perPage) {
          media(type: ANIME, sort: POPULARITY_DESC) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              large
              extraLarge
            }
            bannerImage
            averageScore
            genres
            format
            episodes
            status
          }
        }
      }
    ''';

    final result = await fetchAniList(query, {'page': page, 'perPage': perPage});
    return result['data']['Page']['media'] ?? [];
  }

  static Future<Map<String, dynamic>> getAnimeDetail(int id) async {
    const query = '''
      query (\$id: Int) {
        Media(id: \$id, type: ANIME) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            large
            extraLarge
          }
          bannerImage
          description
          genres
          averageScore
          popularity
          favourites
          rankings {
            rank
            type
          }
          format
          episodes
          duration
          status
          source
          season
          seasonYear
          studios(isMain: true) {
            nodes {
              name
            }
          }
          trailer {
            id
            site
          }
          characters(sort: ROLE, page: 1, perPage: 10) {
            edges {
              role
              node {
                id
                name {
                  full
                }
                image {
                  large
                }
              }
            }
          }
          airingSchedule(notYetAired: false, page: 1, perPage: 50) {
            nodes {
              episode
              airingAt
              timeUntilAiring
            }
          }
        }
      }
    ''';

    final result = await fetchAniList(query, {'id': id});
    return result['data']['Media'] ?? {};
  }

  static Future<List<dynamic>> getAiringSchedule({int page = 1, int perPage = 50}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final weekLater = now + (7 * 24 * 60 * 60);

    const query = '''
      query (\$page: Int, \$perPage: Int, \$airingAtGreater: Int, \$airingAtLesser: Int) {
        Page(page: \$page, perPage: \$perPage) {
          airingSchedules(airingAt_greater: \$airingAtGreater, airingAt_lesser: \$airingAtLesser, sort: TIME) {
            id
            episode
            airingAt
            media {
              id
              title {
                romaji
                english
                native
              }
              coverImage {
                large
              }
              genres
            }
          }
        }
      }
    ''';

    final result = await fetchAniList(query, {
      'page': page,
      'perPage': perPage,
      'airingAtGreater': now,
      'airingAtLesser': weekLater,
    });
    return result['data']['Page']['airingSchedules'] ?? [];
  }

  static Future<List<dynamic>> searchAnime(String search, {int page = 1, int perPage = 20}) async {
    const query = '''
      query (\$search: String, \$page: Int, \$perPage: Int) {
        Page(page: \$page, perPage: \$perPage) {
          media(type: ANIME, search: \$search) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              large
              extraLarge
            }
            bannerImage
            averageScore
            genres
            format
            episodes
            status
          }
        }
      }
    ''';

    final result = await fetchAniList(query, {'search': search, 'page': page, 'perPage': perPage});
    return result['data']['Page']['media'] ?? [];
  }
}