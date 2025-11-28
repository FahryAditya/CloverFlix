import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../api_anillist.dart';
import 'detail_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with AutomaticKeepAliveClientMixin {
  List<dynamic> _schedules = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await AniListAPI.getAiringSchedule(perPage: 100);
      if (mounted) {
        setState(() {
          _schedules = data;
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
            content: Text('Error loading schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, List<dynamic>> _groupSchedulesByDay() {
    final Map<String, List<dynamic>> grouped = {};
    
    for (var schedule in _schedules) {
      final airingAt = DateTime.fromMillisecondsSinceEpoch(
        schedule['airingAt'] * 1000,
      );
      final dayKey = DateFormat('EEEE, MMMM d, y').format(airingAt);
      
      if (!grouped.containsKey(dayKey)) {
        grouped[dayKey] = [];
      }
      grouped[dayKey]!.add(schedule);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No scheduled anime found',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSchedules,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
              ),
            ),
          ],
        ),
      );
    }

    final groupedSchedules = _groupSchedulesByDay();
    final days = groupedSchedules.keys.toList();

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final schedules = groupedSchedules[day]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accent.withOpacity(0.2),
                      AppTheme.accent.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
              ...schedules.map((schedule) => _buildOptimizedScheduleCard(schedule)),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptimizedScheduleCard(dynamic schedule) {
    final media = schedule['media'];
    final title = media['title'];
    final coverImage = media['coverImage'];
    final episode = schedule['episode'];
    final airingAt = DateTime.fromMillisecondsSinceEpoch(
      schedule['airingAt'] * 1000,
    );
    final timeFormat = DateFormat('h:mm a');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(animeId: media['id']),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Hero(
                tag: 'schedule_${media['id']}_$episode',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: coverImage['large'] ?? '',
                    width: 55,
                    height: 78,
                    fit: BoxFit.cover,
                    memCacheHeight: 156,
                    memCacheWidth: 110,
                    placeholder: (context, url) => Container(
                      color: AppTheme.card,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.card,
                      child: const Icon(Icons.error, size: 20, color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title['romaji'] ?? title['english'] ?? 'Unknown',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                        'Episode $episode',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 13,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeFormat.format(airingAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (media['genres'] != null && 
                        (media['genres'] as List).isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: (media['genres'] as List)
                            .take(2)
                            .map((genre) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.card,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppTheme.accent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    genre,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}