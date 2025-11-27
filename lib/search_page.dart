import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:async';
import 'anime.dart';
import 'anime_card.dart';
import 'api_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  List<Anime> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _popularSearches = [
    'Attack on Titan',
    'Demon Slayer',
    'Naruto',
    'One Piece',
    'My Hero Academia',
    'Death Note',
    'Sword Art Online',
    'Tokyo Ghoul',
  ];
  
  bool _isSearching = false;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    setState(() {
      _recentSearches = ['Naruto', 'One Piece', 'Bleach'];
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults.clear();
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    final allAnime = Anime.getDemoAnime();
    final results = allAnime.where((anime) {
      return anime.title.toLowerCase().contains(query.toLowerCase()) ||
             anime.genres.any((g) => g.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.requestFocus();
    setState(() {
      _hasSearched = false;
      _searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E88E5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchBar(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: _onSearchChanged,
        onSubmitted: _performSearch,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search anime...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF1E88E5),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E88E5),
        ),
      );
    }

    if (_hasSearched) {
      return _buildSearchResults();
    }

    return _buildSuggestions();
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: AnimeCard(anime: _searchResults[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionTitle('Recent Searches', Icons.history),
            const SizedBox(height: 12),
            _buildChipList(
              _recentSearches,
              onTap: (query) {
                _searchController.text = query;
                _performSearch(query);
              },
              onDelete: (query) {
                setState(() {
                  _recentSearches.remove(query);
                });
              },
            ),
            const SizedBox(height: 24),
          ],
          _buildSectionTitle('Popular Searches', Icons.trending_up),
          const SizedBox(height: 12),
          _buildChipList(
            _popularSearches,
            onTap: (query) {
              _searchController.text = query;
              _performSearch(query);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1E88E5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildChipList(
    List<String> items, {
    required Function(String) onTap,
    Function(String)? onDelete,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return InputChip(
          label: Text(item),
          avatar: onDelete != null ? const Icon(Icons.history, size: 16) : null,
          deleteIcon: onDelete != null ? const Icon(Icons.close, size: 18) : null,
          onPressed: () => onTap(item),
          onDeleted: onDelete != null ? () => onDelete(item) : null,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              // ignore: deprecated_member_use
              color: const Color(0xFF1E88E5).withOpacity(0.2),
            ),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF1E88E5),
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}
