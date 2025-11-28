import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme.dart';
import '../api_anillist.dart';
import '../models/anime.dart';
import '../widgets/animated_poster_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'detail_page.dart';

class AnimePage extends StatefulWidget {
  const AnimePage({super.key});

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> with AutomaticKeepAliveClientMixin {
  final List<Anime> _animes = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isSearchMode = false;
  bool _showScrollToTop = false;

  String? _selectedGenre;
  String? _selectedStatus;
  String? _selectedSort;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAnimes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show/hide scroll to top button
    if (_scrollController.offset > 500 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 500 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }

    // Load more
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoading && _hasMore && !_isSearchMode) {
        _loadAnimes();
      }
    }
  }

  Future<void> _loadAnimes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await AniListAPI.getPopularAnime(
        page: _currentPage, 
        perPage: 20,
      );
      final newAnimes = data.map((e) => Anime.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _animes.addAll(newAnimes);
          _currentPage++;
          _isLoading = false;
          _hasMore = newAnimes.length == 20;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading anime: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchAnimes(String query) async {
    if (query.isEmpty) {
      setState(() {
        _animes.clear();
        _currentPage = 1;
        _hasMore = true;
        _isSearchMode = false;
      });
      _loadAnimes();
      return;
    }

    setState(() {
      _animes.clear();
      _isLoading = true;
      _isSearchMode = true;
    });

    try {
      final data = await AniListAPI.searchAnime(query, perPage: 30);
      final searchResults = data.map((e) => Anime.fromJson(e)).toList();
      
      if (mounted) {
        setState(() {
          _animes.addAll(searchResults);
          _isLoading = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        selectedGenre: _selectedGenre,
        selectedStatus: _selectedStatus,
        selectedSort: _selectedSort,
        onApply: (genre, status, sort) {
          setState(() {
            _selectedGenre = genre;
            _selectedStatus = status;
            _selectedSort = sort;
          });
          // Apply filters logic here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Filters applied: $genre, $status, $sort'),
              backgroundColor: AppTheme.accent,
            ),
          );
        },
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search anime...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.accent),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchAnimes('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSubmitted: _searchAnimes,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: AppTheme.accent),
                    onPressed: _showFilterSheet,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _animes.isEmpty && _isLoading
                ? const ShimmerGrid(itemCount: 12)
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _animes.clear();
                        _currentPage = 1;
                        _hasMore = true;
                        _isSearchMode = false;
                      });
                      await _loadAnimes();
                    },
                    child: AnimationLimiter(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3 / 4.8, // Perfect for 3:4 poster + title
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _animes.length + (_hasMore && !_isSearchMode ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _animes.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final anime = _animes[index];
                          
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
                                  heroTag: 'anime_${anime.id}',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailPage(animeId: anime.id),
                                      ),
                                    );
                                  },
                                  badge: anime.status == 'RELEASING'
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'AIRING',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : null,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: AppTheme.accent,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }
}