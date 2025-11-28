import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../api_anillist.dart';
import '../models/anime.dart';
import '../services/storage_service.dart';

class DetailPage extends StatefulWidget {
  final int animeId;

  const DetailPage({super.key, required this.animeId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Anime? _anime;
  bool _isLoading = true;
  bool _showFullDescription = false;
  bool _isFavorite = false;
  bool _isInWatchlist = false;
  bool _isWatching = false;

  @override
  void initState() {
    super.initState();
    _loadAnimeDetail();
    _checkListStatus();
  }

  Future<void> _loadAnimeDetail() async {
    try {
      final data = await AniListAPI.getAnimeDetail(widget.animeId);
      if (mounted) {
        setState(() {
          _anime = Anime.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading detail: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkListStatus() async {
    _isFavorite = await StorageService.isFavorite(widget.animeId, 'anime');
    _isInWatchlist = await StorageService.isInWatchlist(widget.animeId, 'anime');
    _isWatching = await StorageService.isWatching(widget.animeId, 'anime');
    if (mounted) setState(() {});
  }

  Future<void> _toggleFavorite() async {
    if (_anime == null) return;

    if (_isFavorite) {
      await StorageService.removeFromFavorites(widget.animeId, 'anime');
    } else {
      await StorageService.addToFavorites({
        'id': _anime!.id,
        'type': 'anime',
        'title': _anime!.titleEnglish ?? _anime!.titleRomaji,
        'coverImage': _anime!.coverImage,
        'score': _anime!.score,
      });
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        backgroundColor: AppTheme.accent,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleWatchlist() async {
    if (_anime == null) return;

    if (_isInWatchlist) {
      await StorageService.removeFromWatchlist(widget.animeId, 'anime');
    } else {
      await StorageService.addToWatchlist({
        'id': _anime!.id,
        'type': 'anime',
        'title': _anime!.titleEnglish ?? _anime!.titleRomaji,
        'coverImage': _anime!.coverImage,
        'score': _anime!.score,
      });
    }

    setState(() {
      _isInWatchlist = !_isInWatchlist;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isInWatchlist ? 'Added to watchlist' : 'Removed from watchlist'),
        backgroundColor: AppTheme.accent,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleWatching() async {
    if (_anime == null) return;

    if (_isWatching) {
      await StorageService.removeFromWatching(widget.animeId, 'anime');
    } else {
      await StorageService.addToWatching({
        'id': _anime!.id,
        'type': 'anime',
        'title': _anime!.titleEnglish ?? _anime!.titleRomaji,
        'coverImage': _anime!.coverImage,
        'score': _anime!.score,
      });
    }

    setState(() {
      _isWatching = !_isWatching;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isWatching ? 'Added to watching' : 'Removed from watching'),
        backgroundColor: AppTheme.accent,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareAnime() {
    if (_anime == null) return;
    
    final title = _anime!.titleEnglish ?? _anime!.titleRomaji;
    final url = 'https://anilist.co/anime/${_anime!.id}';
    
    Share.share(
      'Check out $title on AniList!\n\n$url',
      subject: title,
    );
  }

  void _playTrailer() {
    if (_anime?.trailerId != null && _anime?.trailerSite == 'youtube') {
      final controller = YoutubePlayerController(
        initialVideoId: _anime!.trailerId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          controlsVisibleAtStart: true,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _TrailerPlayerPage(controller: controller),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_anime == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load anime details'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPosterAndTitle(),
                _buildActionButtons(),
                _buildGenres(),
                _buildCategoryButtons(),
                if (_anime!.trailerId != null) _buildModernTrailer(),
                _buildDescription(),
                _buildInfoBox(),
                _buildStatsBox(),
                if (_anime!.characters.isNotEmpty) _buildCharacters(),
                if (_anime!.airingSchedules.isNotEmpty) _buildEpisodeList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareAnime,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_anime!.bannerImage != null)
              CachedNetworkImage(
                imageUrl: _anime!.bannerImage!,
                fit: BoxFit.cover,
                memCacheHeight: 560,
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.card,
                ),
              )
            else
              CachedNetworkImage(
                imageUrl: _anime!.coverImage,
                fit: BoxFit.cover,
                memCacheHeight: 560,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                    AppTheme.background,
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterAndTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'anime_${_anime!.id}',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _anime!.coverImage,
                  width: 120,
                  height: 160, // 3:4 ratio
                  fit: BoxFit.cover,
                  memCacheHeight: 320,
                  memCacheWidth: 240,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _anime!.titleRomaji,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_anime!.titleEnglish != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _anime!.titleEnglish!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_anime!.titleNative != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _anime!.titleNative!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              Icons.favorite,
              _isFavorite ? 'Favorited' : 'Favorite',
              _isFavorite ? Colors.red : AppTheme.textSecondary,
              _toggleFavorite,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              Icons.bookmark,
              _isInWatchlist ? 'In List' : 'Watchlist',
              _isInWatchlist ? Colors.blue : AppTheme.textSecondary,
              _toggleWatchlist,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              Icons.play_circle,
              _isWatching ? 'Watching' : 'Watch',
              _isWatching ? Colors.green : AppTheme.textSecondary,
              _toggleWatching,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenres() {
    if (_anime!.genres.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _anime!.genres.map((genre) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.accent.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Text(
              genre,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildCategoryButton('Anime', Icons.movie_outlined),
          _buildCategoryButton('Manga', Icons.book_outlined),
          _buildCategoryButton('Light Novel', Icons.auto_stories_outlined),
          _buildCategoryButton('Webpage', Icons.language),
          _buildCategoryButton('Characters', Icons.people_outline),
          _buildCategoryButton('Studio', Icons.business_outlined),
          _buildCategoryButton('Episodes', Icons.list_alt),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, IconData icon) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.textSecondary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTrailer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.play_circle_outline, color: AppTheme.accent, size: 24),
              SizedBox(width: 8),
              Text(
                'Trailer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _playTrailer,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: 'https://img.youtube.com/vi/${_anime!.trailerId}/maxresdefault.jpg',
                      fit: BoxFit.cover,
                      memCacheHeight: 400,
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.card,
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.video_library, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Watch on YouTube',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... Continued in next part (Description, Info, Stats, Characters, Episodes)
  
  Widget _buildDescription() {
    if (_anime!.description == null) return const SizedBox.shrink();

    String description = _anime!.description!
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    final lines = description.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final displayText = _showFullDescription
        ? description
        : (lines.length > 5 ? lines.take(5).join('\n') + '...' : description);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Synopsis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          if (lines.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showFullDescription = !_showFullDescription;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showFullDescription ? 'Show Less' : 'Read More',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showFullDescription 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                        color: AppTheme.accent,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accent.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accent, size: 22),
              SizedBox(width: 8),
              Text(
                'Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Format', _anime!.format ?? 'N/A'),
          _buildInfoRow('Episodes', _anime!.episodes?.toString() ?? 'N/A'),
          _buildInfoRow('Duration', _anime!.duration != null ? '${_anime!.duration} min' : 'N/A'),
          _buildInfoRow('Status', _anime!.status ?? 'N/A'),
          _buildInfoRow('Source', _anime!.source ?? 'N/A'),
          _buildInfoRow(
            'Season',
            _anime!.season != null && _anime!.seasonYear != null
                ? '${_anime!.season} ${_anime!.seasonYear}'
                : 'N/A',
          ),
          _buildInfoRow('Studio', _anime!.studio ?? 'N/A', isLast: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Score',
              _anime!.score != null ? '${(_anime!.score! / 10).toStringAsFixed(1)}' : 'N/A',
              Icons.star_rounded,
              Colors.amber,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'Rank',
              _anime!.rank != null ? '#${_anime!.rank}' : 'N/A',
              Icons.trending_up_rounded,
              Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'Popularity',
              _anime!.popularity != null ? '#${_anime!.popularity}' : 'N/A',
              Icons.people_rounded,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'Favorites',
              _anime!.favourites != null ? _formatNumber(_anime!.favourites!) : 'N/A',
              Icons.favorite_rounded,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.people, color: AppTheme.accent, size: 22),
                SizedBox(width: 8),
                Text(
                  'Characters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _anime!.characters.length,
              itemBuilder: (context, index) {
                final character = _anime!.characters[index];
                return Container(
                  width: 110,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 0,
                    right: 12,
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: character.image,
                          width: 110,
                          height: 130,
                          fit: BoxFit.cover,
                          memCacheHeight: 260,
                          memCacheWidth: 220,
                          placeholder: (context, url) => Container(
                            color: AppTheme.card,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.card,
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        character.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        character.role,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tv, color: AppTheme.accent, size: 22),
              SizedBox(width: 8),
              Text(
                'Episodes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._anime!.airingSchedules.take(10).map((schedule) {
            final dateFormat = DateFormat('MMMM d, y');
            final timeFormat = DateFormat('h:mm a');
            final date = schedule.airingDateTime;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accent.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accent,
                          AppTheme.accent.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${schedule.episode}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Episode ${schedule.episode}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeFormat.format(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _TrailerPlayerPage extends StatefulWidget {
  final YoutubePlayerController controller;

  const _TrailerPlayerPage({required this.controller});

  @override
  State<_TrailerPlayerPage> createState() => _TrailerPlayerPageState();
}

class _TrailerPlayerPageState extends State<_TrailerPlayerPage> {
  @override
  void dispose() {
    widget.controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: widget.controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.accent,
          onReady: () {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          },
        ),
      ),
    );
  }
}