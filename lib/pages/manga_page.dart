import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme.dart';
import '../api_mangadex.dart';
import '../models/manga.dart';
import '../widgets/animated_poster_card.dart';
import '../widgets/shimmer_loading.dart';

class MangaPage extends StatefulWidget {
  const MangaPage({super.key});

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> with AutomaticKeepAliveClientMixin {
  final List<Manga> _mangas = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _currentOffset = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isSearching = false;
  bool _showScrollToTop = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMangas();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 500 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 500 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }

    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoading && _hasMore) {
        _loadMangas();
      }
    }
  }

  Future<void> _loadMangas() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = _isSearching
          ? await MangaDexAPI.searchManga(
              _searchController.text,
              limit: 20,
              offset: _currentOffset,
            )
          : await MangaDexAPI.getTrendingManga(
              limit: 20,
              offset: _currentOffset,
            );

      final newMangas = data.map((e) => Manga.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _mangas.addAll(newMangas);
          _currentOffset += 20;
          _isLoading = false;
          _hasMore = newMangas.length == 20;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading manga: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchManga(String query) {
    setState(() {
      _mangas.clear();
      _currentOffset = 0;
      _isSearching = query.isNotEmpty;
      _hasMore = true;
    });
    _loadMangas();
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search manga...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.accent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchManga('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _searchManga,
            ),
          ),
          Expanded(
            child: _mangas.isEmpty && _isLoading
                ? const ShimmerGrid(itemCount: 12)
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _mangas.clear();
                        _currentOffset = 0;
                        _hasMore = true;
                      });
                      await _loadMangas();
                    },
                    child: AnimationLimiter(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3 / 4.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _mangas.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _mangas.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final manga = _mangas[index];
                          
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            columnCount: 3,
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: AnimatedPosterCard(
                                  imageUrl: manga.image,
                                  title: manga.title,
                                  heroTag: 'manga_${manga.id}',
                                  onTap: () {},
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