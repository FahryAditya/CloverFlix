import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';
import 'episode.dart';
import 'anime.dart';
import 'api_service.dart';

class EpisodePlayerPage extends StatefulWidget {
  final Episode episode;
  final Anime anime;

  const EpisodePlayerPage({
    super.key,
    required this.episode,
    required this.anime,
  });

  @override
  State<EpisodePlayerPage> createState() => _EpisodePlayerPageState();
}

class _EpisodePlayerPageState extends State<EpisodePlayerPage> {
  late YoutubePlayerController _controller;
  final ApiService _apiService = ApiService();
  Timer? _progressTimer;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startProgressTracking();
  }

  void _initializePlayer() {
    // Extract YouTube video ID from URL
    final videoId = YoutubePlayer.convertUrlToId(widget.episode.videoUrl) ?? '';
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        loop: false,
        forceHD: false,
        controlsVisibleAtStart: true,
      ),
    )..addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() => _isFullScreen = _controller.value.isFullScreen);
      
      // Update orientation based on fullscreen state
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    }
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller.value.isPlaying) {
        _saveProgress();
      }
    });
  }

  Future<void> _saveProgress() async {
    final position = _controller.value.position.inSeconds;
    final duration = _controller.metadata.duration.inSeconds;
    
    if (position > 0 && duration > 0) {
      await _apiService.saveWatchHistory(
        animeId: widget.anime.id,
        episodeId: widget.episode.id,
        progress: position,
        duration: duration,
      );
      
      // Update local episode progress
      widget.episode.watchProgress = position;
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _saveProgress(); // Save one last time
    _controller.dispose();
    
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF1E88E5),
        topActions: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.episode.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        bottomActions: [
          CurrentPosition(),
          ProgressBar(
            isExpanded: true,
            colors: const ProgressBarColors(
              playedColor: Color(0xFF1E88E5),
              handleColor: Color(0xFF1E88E5),
            ),
          ),
          RemainingDuration(),
          const PlaybackSpeedButton(),
          FullScreenButton(),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Player
                Hero(
                  tag: 'episode_${widget.episode.id}',
                  child: player,
                ),
                
                // Episode info and controls
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F7FA),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEpisodeInfo(),
                          _buildAnimeInfo(),
                          _buildNextEpisodeButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEpisodeInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E88E5)),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Episode ${widget.episode.episodeNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.episode.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.episode.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.anime.thumbnailUrl,
              width: 60,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 80,
                  color: const Color(0xFF1E88E5),
                  child: const Icon(Icons.movie, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.anime.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.anime.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.anime.totalEpisodes} episodes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
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
  }

  Widget _buildNextEpisodeButton() {
    // Check if there's a next episode
    final hasNextEpisode = widget.episode.episodeNumber < widget.anime.totalEpisodes;
    
    if (!hasNextEpisode) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to next episode
          // In a real app, you'd fetch the next episode and navigate
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Next episode feature coming soon!')),
          );
        },
        icon: const Icon(Icons.skip_next),
        label: Text('Next Episode (${widget.episode.episodeNumber + 1})'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
// =========================
// =     HISTORY PAGE      =
// =========================

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Watch History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: const Center(
        child: Text(
          "Belum ada riwayat tontonan.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
