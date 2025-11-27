class Episode {
  final String id;
  final String animeId;
  final int episodeNumber;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final int duration; // in seconds
  final DateTime? releaseDate;
  int watchProgress; // in seconds

  Episode({
    required this.id,
    required this.animeId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    this.releaseDate,
    this.watchProgress = 0,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? '',
      animeId: json['anime_id']?.toString() ?? json['animeId']?.toString() ?? '',
      episodeNumber: json['episode_number'] ?? json['episodeNumber'] ?? 0,
      title: json['title'] ?? 'Episode ${json['episode_number'] ?? json['episodeNumber'] ?? 0}',
      description: json['description'] ?? 'No description available',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '',
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      duration: json['duration'] ?? 1440, // default 24 minutes
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'])
          : null,
      watchProgress: json['watch_progress'] ?? json['watchProgress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anime_id': animeId,
      'episode_number': episodeNumber,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'duration': duration,
      'release_date': releaseDate?.toIso8601String(),
      'watch_progress': watchProgress,
    };
  }

  // Get watch percentage
  double get watchPercentage {
    if (duration == 0) return 0.0;
    return (watchProgress / duration).clamp(0.0, 1.0);
  }

  // Check if episode is watched (>90%)
  bool get isWatched => watchPercentage >= 0.9;

  // For demo/testing purposes
  static List<Episode> getDemoEpisodes(String animeId) {
    return List.generate(
      12,
      (index) => Episode(
        id: '${animeId}_ep_${index + 1}',
        animeId: animeId,
        episodeNumber: index + 1,
        title: 'Episode ${index + 1}',
        description: 'The story continues in episode ${index + 1}...',
        thumbnailUrl: 'https://via.placeholder.com/320x180/1E88E5/FFFFFF?text=Ep+${index + 1}',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Demo URL
        duration: 1440, // 24 minutes
        releaseDate: DateTime.now().subtract(Duration(days: 12 - index)),
        watchProgress: index < 3 ? (index + 1) * 300 : 0, // First 3 partially watched
      ),
    );
  }
}