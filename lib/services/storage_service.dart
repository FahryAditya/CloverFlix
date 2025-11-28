import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _watchlistKey = 'watchlist';
  static const String _watchingKey = 'currently_watching';
  static const String _searchHistoryKey = 'search_history';

  // Favorites
  static Future<void> addToFavorites(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    final itemWithTimestamp = {
      ...item,
      'addedAt': DateTime.now().toIso8601String(),
    };
    
    favorites.removeWhere((fav) => fav['id'] == item['id'] && fav['type'] == item['type']);
    favorites.insert(0, itemWithTimestamp);
    
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  static Future<void> removeFromFavorites(int id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    favorites.removeWhere((item) => item['id'] == id && item['type'] == type);
    
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(favoritesJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<bool> isFavorite(int id, String type) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item['id'] == id && item['type'] == type);
  }

  // Watchlist
  static Future<void> addToWatchlist(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = await getWatchlist();
    
    final itemWithTimestamp = {
      ...item,
      'addedAt': DateTime.now().toIso8601String(),
    };
    
    watchlist.removeWhere((w) => w['id'] == item['id'] && w['type'] == item['type']);
    watchlist.insert(0, itemWithTimestamp);
    
    await prefs.setString(_watchlistKey, jsonEncode(watchlist));
  }

  static Future<void> removeFromWatchlist(int id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = await getWatchlist();
    
    watchlist.removeWhere((item) => item['id'] == id && item['type'] == type);
    
    await prefs.setString(_watchlistKey, jsonEncode(watchlist));
  }

  static Future<List<Map<String, dynamic>>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? watchlistJson = prefs.getString(_watchlistKey);
    
    if (watchlistJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(watchlistJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<bool> isInWatchlist(int id, String type) async {
    final watchlist = await getWatchlist();
    return watchlist.any((item) => item['id'] == id && item['type'] == type);
  }

  // Currently Watching
  static Future<void> addToWatching(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final watching = await getWatching();
    
    final itemWithTimestamp = {
      ...item,
      'addedAt': DateTime.now().toIso8601String(),
    };
    
    watching.removeWhere((w) => w['id'] == item['id'] && w['type'] == item['type']);
    watching.insert(0, itemWithTimestamp);
    
    await prefs.setString(_watchingKey, jsonEncode(watching));
  }

  static Future<void> removeFromWatching(int id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final watching = await getWatching();
    
    watching.removeWhere((item) => item['id'] == id && item['type'] == type);
    
    await prefs.setString(_watchingKey, jsonEncode(watching));
  }

  static Future<List<Map<String, dynamic>>> getWatching() async {
    final prefs = await SharedPreferences.getInstance();
    final String? watchingJson = prefs.getString(_watchingKey);
    
    if (watchingJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(watchingJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<bool> isWatching(int id, String type) async {
    final watching = await getWatching();
    return watching.any((item) => item['id'] == id && item['type'] == type);
  }

  // Search History
  static Future<void> addToSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getSearchHistory();
    
    history.remove(query);
    history.insert(0, query);
    
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    
    await prefs.setStringList(_searchHistoryKey, history);
  }

  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }
}