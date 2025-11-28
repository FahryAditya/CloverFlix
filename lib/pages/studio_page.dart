import 'package:flutter/material.dart';
import '../theme.dart';

class StudioPage extends StatelessWidget {
  const StudioPage({super.key});

  static final List<Map<String, dynamic>> _studios = [
    {'name': 'Studio Ghibli', 'icon': Icons.nature_people, 'color': Colors.green},
    {'name': 'Kyoto Animation', 'icon': Icons.brush, 'color': Colors.purple},
    {'name': 'MAPPA', 'icon': Icons.movie_creation, 'color': Colors.red},
    {'name': 'ufotable', 'icon': Icons.auto_awesome, 'color': Colors.orange},
    {'name': 'Bones', 'icon': Icons.flash_on, 'color': Colors.yellow},
    {'name': 'Production I.G', 'icon': Icons.sports_kabaddi, 'color': Colors.blue},
    {'name': 'Madhouse', 'icon': Icons.star, 'color': Colors.cyan},
    {'name': 'Wit Studio', 'icon': Icons.landscape, 'color': Colors.teal},
    {'name': 'A-1 Pictures', 'icon': Icons.palette, 'color': Colors.pink},
    {'name': 'Trigger', 'icon': Icons.electric_bolt, 'color': Colors.amber},
    {'name': 'Shaft', 'icon': Icons.architecture, 'color': Colors.indigo},
    {'name': 'J.C.Staff', 'icon': Icons.videocam, 'color': Colors.deepOrange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Studios'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _studios.length,
        itemBuilder: (context, index) {
          final studio = _studios[index];
          return _buildStudioCard(
            context,
            studio['name'],
            studio['icon'],
            studio['color'],
          );
        },
      ),
    );
  }

  Widget _buildStudioCard(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
  ) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $name...'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}