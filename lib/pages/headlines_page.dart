import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../api_anillist.dart';
import '../models/anime.dart';
import 'detail_page.dart';

class HeadlinesPage extends StatefulWidget {
  const HeadlinesPage({super.key});

  @override
  State<HeadlinesPage> createState() => _HeadlinesPageState();
}

class _HeadlinesPageState extends State<HeadlinesPage> {
  List<Anime> _headlines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHeadlines();
  }

  Future<void> _loadHeadlines() async {
    setState(() => _isLoading = true);

    try {
      final data = await AniListAPI.getTrendingAnime(perPage: 20);
      final animes = data.map((e) => Anime.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _headlines = animes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading headlines: $e'),
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
        title: const Text('Anime Headlines'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHeadlines,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _headlines.length,
                itemBuilder: (context, index) {
                  final anime = _headlines[index];
                  return _buildHeadlineCard(anime, index);
                },
              ),
            ),
    );
  }

  Widget _buildHeadlineCard(Anime anime, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accent.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(animeId: anime.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (anime.bannerImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: anime.bannerImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      memCacheHeight: 360,
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (anime.status == 'RELEASING')
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            'AIRING NOW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.titleEnglish ?? anime.titleRomaji,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (anime.description != null)
                    Text(
                      anime.description!
                          .replaceAll(RegExp(r'<[^>]*>'), '')
                          .replaceAll('&quot;', '"')
                          .replaceAll('&amp;', '&'),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (anime.score != null) ...[
                        Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(anime.score! / 10).toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(now),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (anime.format != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            anime.format!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (anime.genres.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: anime.genres.take(4).map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppTheme.textSecondary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}