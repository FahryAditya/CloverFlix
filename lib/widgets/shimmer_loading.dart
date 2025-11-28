import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.card,
      highlightColor: AppTheme.card.withOpacity(0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ShimmerPosterCard extends StatelessWidget {
  final double width;

  const ShimmerPosterCard({
    super.key,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 4 / 3; // 3:4 ratio

    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            width: width,
            height: height,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 6),
          ShimmerLoading(
            width: width * 0.8,
            height: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          ShimmerLoading(
            width: width * 0.6,
            height: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerGrid({
    super.key,
    this.itemCount = 9,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 4.5, // Adjusted for 3:4 poster + title
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerPosterCard(width: double.infinity);
      },
    );
  }
}

class ShimmerHorizontalList extends StatelessWidget {
  final int itemCount;
  final double cardWidth;

  const ShimmerHorizontalList({
    super.key,
    this.itemCount = 5,
    this.cardWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (cardWidth * 4 / 3) + 50, // Height + title space
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ShimmerPosterCard(width: cardWidth),
          );
        },
      ),
    );
  }
}