import 'package:flutter/material.dart';
import '../theme.dart';

class SeasonArchivePage extends StatefulWidget {
  const SeasonArchivePage({super.key});

  @override
  State<SeasonArchivePage> createState() => _SeasonArchivePageState();
}

class _SeasonArchivePageState extends State<SeasonArchivePage> {
  final int _currentYear = DateTime.now().year;
  final List<String> _seasons = ['WINTER', 'SPRING', 'SUMMER', 'FALL'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Season Archive'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Last 5 years
        itemBuilder: (context, yearIndex) {
          final year = _currentYear - yearIndex;
          return _buildYearSection(year);
        },
      ),
    );
  }

  Widget _buildYearSection(int year) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            year.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _seasons.length,
          itemBuilder: (context, index) {
            final season = _seasons[index];
            return _buildSeasonCard(season, year);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSeasonCard(String season, int year) {
    IconData icon;
    Color color;

    switch (season) {
      case 'WINTER':
        icon = Icons.ac_unit;
        color = Colors.cyan;
        break;
      case 'SPRING':
        icon = Icons.local_florist;
        color = Colors.pink;
        break;
      case 'SUMMER':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 'FALL':
        icon = Icons.park;
        color = Colors.brown;
        break;
      default:
        icon = Icons.calendar_today;
        color = AppTheme.accent;
    }

    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $season $year...'),
              duration: const Duration(seconds: 1),
            ),
          );
          // TODO: Navigate to season detail page
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  season,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}