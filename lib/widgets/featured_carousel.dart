import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';

import '../theme.dart';
import '../models/anime.dart';

class FeaturedCarousel extends StatefulWidget {
  final List<Anime> animes;
  final Function(int) onTap;

  const FeaturedCarousel({
    super.key,
    required this.animes,
    required this.onTap,
  });

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.animes.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Swiper(
            autoplay: true,
            viewportFraction: 0.9,
            scale: 0.9,
            itemCount:
                widget.animes.length > 5 ? 5 : widget.animes.length,
            onIndexChanged: (index) {
              setState(() => _current = index);
            },
            itemBuilder: (context, index) {
              return _buildCarouselItem(widget.animes[index]);
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.animes.length > 5 ? 5 : widget.animes.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _current == index ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _current == index
                    ? AppTheme.accent
                    : AppTheme.textSecondary.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselItem(Anime anime) {
    return GestureDetector(
      onTap: () => widget.onTap(anime.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: anime.bannerImage ?? anime.coverImage,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
