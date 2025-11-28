import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme.dart';
import '../api_anillist.dart';
import '../services/storage_service.dart';
import '../models/anime.dart';
import '../widgets/animated_poster_card.dart';
import '../widgets/shimmer_loading.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<Anime> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final history = await StorageService.getSearchHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      await StorageService.addToSearchHistory(query);
      final data = await AniListAPI.searchAnime(query, perPage: 30);
      
      if (mounted) {
        setState(() {
          _searchResults = data.map((e) => Anime.fromJson(e)).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search anime, manga, manhwa...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          style: const TextStyle(fontSize: 16),
          onSubmitted: _performSearch,
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                _showResults = false;
                _searchResults.clear();
              });
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _showResults = false;
                  _searchResults.clear();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _showResults
          ? _buildSearchResults()
          : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await StorageService.clearSearchHistory();
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppTheme.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.take(10).map((query) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          query,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
          const Text(
            'Trending Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildTrendingSearches(),
        ],
      ),
    );
  }

  List<Widget> _buildTrendingSearches() {
    final trending = [
      'One Piece',
      'Jujutsu Kaisen',
      'Attack on Titan',
      'Demon Slayer',
      'My Hero Academia',
      'Chainsaw Man',
      'Spy x Family',
      'Tokyo Revengers',
    ];

    return trending.map((search) {
      return InkWell(
        onTap: () {
          _searchController.text = search;
          _performSearch(search);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.textSecondary.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: AppTheme.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  search,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const ShimmerGrid(itemCount: 9);
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 4.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final anime = _searchResults[index];
          
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 3,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: AnimatedPosterCard(
                  imageUrl: anime.coverImage,
                  title: anime.titleEnglish ?? anime.titleRomaji,
                  score: anime.score?.toDouble(),
                  heroTag: 'search_${anime.id}',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(animeId: anime.id),
                      ),
                    );
                  },
                  width: double.infinity,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}