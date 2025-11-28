import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme.dart';
import '../api_anillist.dart';
import '../models/anime.dart';
import '../widgets/animated_poster_card.dart';
import '../widgets/shimmer_loading.dart';
import 'detail_page.dart';

class CurrentSeasonPage extends StatefulWidget {
  const CurrentSeasonPage({super.key});

  @override
  State<CurrentSeasonPage> createState() => _CurrentSeasonPageState();
}

class _CurrentSeasonPageState extends State<CurrentSeasonPage> {
  List<Anime> _animes = [];
  bool _isLoading = true;
  String _currentSeason = '';
  int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _getCurrentSeason();
    _loadSeasonAnime();
  }

  void _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 1 && month <= 3) {
      _currentSeason = 'WINTER';
    } else if (month >= 4 && month <= 6) {
      _currentSeason = 'SPRING';
    } else if (month >= 7 && month <= 9) {
      _currentSeason = 'SUMMER';
    } else {
      _currentSeason = 'FALL';
    }
  }

  Future<void> _loadSeasonAnime() async {
    setState(() => _isLoading = true);

    try {
      final data = await AniListAPI.getTrendingAnime(perPage: 50);
      final animes = data.map((e) => Anime.fromJson(e)).toList();
      
      // Filter by current season
      final seasonAnimes = animes.where((anime) {
        return anime.season == _currentSeason && 
               anime.seasonYear == _currentYear &&
               (anime.status == 'RELEASING' || anime.status == 'NOT_YET_RELEASED');
      }).toList();

      if (mounted) {
        setState(() {
          _animes = seasonAnimes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading season: $e'),
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
        title: Text('$_currentSeason $_currentYear'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Current Season'),
                  content: Text(
                    'Showing anime from $_currentSeason $_currentYear that are currently airing or upcoming.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const ShimmerGrid(itemCount: 12)
          : _animes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSeasonAnime,
                  child: AnimationLimiter(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 4.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _animes.length,
                      itemBuilder: (context, index) {
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
                                heroTag: 'season_${anime.id}',
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
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'UPCOMING',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                width: double.infinity,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No anime this season',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new releases',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}