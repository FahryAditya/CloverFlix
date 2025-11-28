import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../theme.dart';
import '../api_anillist.dart';
import '../api_mangadex.dart';

import '../models/anime.dart';
import '../models/manga.dart';

import '../widgets/animated_poster_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/costom_navbar.dart';  // FIXED: costom_navbar → custom_navbar

// PAGES
import 'anime_page.dart';
import 'manga_page.dart';
import 'schedule_page.dart';
import 'detail_page.dart';
import 'my_list_page.dart';              // FIXED PATH
import 'search_page.dart';
import 'current_season.dart';
import 'season_archive.dart';
import 'headlines_page.dart';
import 'videos_page.dart';
import 'studio_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  late TabController _tabController;

  List<Anime> _featuredAnimes = [];
  List<Anime> _trendingAnimes = [];
  List<Manga> _trendingMangas = [];

  bool _isLoadingFeatured = true;
  bool _isLoadingAnime = true;
  bool _isLoadingManga = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    _loadFeatured();
    _loadTrendingAnime();
    _loadTrendingManga();
  }

  Future<void> _loadFeatured() async {
    try {
      final data = await AniListAPI.getTrendingAnime(perPage: 5);
      if (!mounted) return;
      setState(() {
        _featuredAnimes = data.map((e) => Anime.fromJson(e)).toList();
        _isLoadingFeatured = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFeatured = false);
      }
    }
  }

  Future<void> _loadTrendingAnime() async {
    try {
      final data = await AniListAPI.getTrendingAnime(perPage: 10);
      if (!mounted) return;
      setState(() {
        _trendingAnimes = data.map((e) => Anime.fromJson(e)).toList();
        _isLoadingAnime = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAnime = false);
      }
    }
  }

  Future<void> _loadTrendingManga() async {
    try {
      final data = await MangaDexAPI.getTrendingManga(limit: 10);
      if (!mounted) return;
      setState(() {
        _trendingMangas = data.map((e) => Manga.fromJson(e)).toList();
        _isLoadingManga = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingManga = false);
      }
    }
  }

  void _handleNavbarMenu(String menu) {
    Widget page;

    switch (menu) {
      case 'current_season':
        page = const CurrentSeasonPage();
        break;
      case 'schedule':
        _tabController.animateTo(3);
        return;
      case 'season':
        page = const SeasonArchivePage();
        break;
      case 'headlines':
        page = const HeadlinesPage();
        break;
      case 'videos':
        page = const VideosPage();
        break;
      case 'studio':
        page = const StudioPage();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimeHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListsPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.movie), text: 'Anime'),
            Tab(icon: Icon(Icons.book), text: 'Manga'),
            Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomePage(),
          const AnimePage(),
          const MangaPage(),
          const SchedulePage(),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                const SizedBox(height: 16),

                if (_isLoadingFeatured)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ShimmerLoading(
                      width: double.infinity,
                      height: 200,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  )
                else if (_featuredAnimes.isNotEmpty)
                  FeaturedCarousel(
                    animes: _featuredAnimes,
                    onTap: (id) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(animeId: id),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 16),
                CustomNavbar(onMenuTap: _handleNavbarMenu),
                const SizedBox(height: 8),

                _buildSection(
                  '🔥 Trending Anime',
                  _isLoadingAnime
                      ? const ShimmerHorizontalList(cardWidth: 120)
                      : _buildAnimeList(),
                  onSeeAll: () => _tabController.animateTo(1),
                ),

                _buildSection(
                  '📚 Popular Manga',
                  _isLoadingManga
                      ? const ShimmerHorizontalList(cardWidth: 120)
                      : _buildMangaList(),
                  onSeeAll: () => _tabController.animateTo(2),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    Widget content, {
    VoidCallback? onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'See All',
                    style: TextStyle(color: AppTheme.accent),
                  ),
                ),
            ],
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildAnimeList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: _trendingAnimes.length,
        itemBuilder: (context, index) {
          final anime = _trendingAnimes[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedPosterCard(
              imageUrl: anime.coverImage,
              title: anime.titleEnglish ?? anime.titleRomaji,
              score: anime.score?.toDouble(),
              heroTag: 'home_anime_${anime.id}',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(animeId: anime.id),
                  ),
                );
              },
              badge: anime.status == 'RELEASING'
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AIRING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
              width: 120,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMangaList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: _trendingMangas.length,
        itemBuilder: (context, index) {
          final manga = _trendingMangas[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedPosterCard(
              imageUrl: manga.image,
              title: manga.title,
              heroTag: 'home_manga_${manga.id}',
              onTap: () {},
              width: 120,
            ),
          );
        },
      ),
    );
  }
}
