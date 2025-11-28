import 'package:flutter/material.dart';
import '../theme.dart';

class CustomNavbar extends StatelessWidget {
  final Function(String) onMenuTap;

  const CustomNavbar({
    super.key,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accent.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.calendar_today,
            label: 'Current\nSeason',
            onTap: () => onMenuTap('current_season'),
          ),
          _buildDivider(),
          _buildNavItem(
            icon: Icons.schedule,
            label: 'Schedule',
            onTap: () => onMenuTap('schedule'),
          ),
          _buildDivider(),
          _buildNavItem(
            icon: Icons.movie,
            label: 'Season',
            onTap: () => onMenuTap('season'),
          ),
          _buildDivider(),
          _buildNavItem(
            icon: Icons.article,
            label: 'Headlines',
            onTap: () => onMenuTap('headlines'),
          ),
          _buildDivider(),
          _buildNavItem(
            icon: Icons.video_library,
            label: 'Videos',
            onTap: () => onMenuTap('videos'),
          ),
          _buildDivider(),
          _buildNavItem(
            icon: Icons.business,
            label: 'Studio',
            onTap: () => onMenuTap('studio'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: AppTheme.accent,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.textSecondary.withOpacity(0.2),
    );
  }
}