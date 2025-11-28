import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme.dart';
import '../services/storage_service.dart';
import '../widgets/animated_poster_card.dart';
import 'detail_page.dart';

class MyListsPage extends StatefulWidget {
  const MyListsPage({super.key});

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _watchlist = [];
  List<Map<String, dynamic>> _watching = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _favorites = await StorageService.getFavorites();
    _watchlist = await StorageService.getWatchlist();
    _watching = await StorageService.getWatching();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            Tab(
              icon: const Icon(Icons.favorite),
              text: 'Favorites (${_favorites.length})',
            ),
            Tab(
              icon: const Icon(Icons.bookmark),
              text: 'Watchlist (${_watchlist.length})',
            ),
            Tab(
              icon: const Icon(Icons.play_circle),
              text: 'Watching (${_watching.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListView(_favorites, 'favorites'),
                _buildListView(_watchlist, 'watchlist'),
                _buildListView(_watching, 'watching'),
              ],
            ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> items, String listType) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              listType == 'favorites'
                  ? Icons.favorite_border
                  : listType == 'watchlist'
                      ? Icons.bookmark_border
                      : Icons.play_circle_outline,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No items in ${listType == 'favorites' ? 'favorites' : listType}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 4.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 3,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: AnimatedPosterCard(
                  imageUrl: item['coverImage'] ?? '',
                  title: item['title'] ?? 'Unknown',
                  score: item['score']?.toDouble(),
                  heroTag: '${listType}_${item['id']}',
                  onTap: () {
                    if (item['type'] == 'anime') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(animeId: item['id']),
                        ),
                      ).then((_) => _loadData());
                    }
                  },
                  badge: _buildListBadge(listType),
                  width: double.infinity,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListBadge(String listType) {
    IconData icon;
    Color color;

    switch (listType) {
      case 'favorites':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case 'watchlist':
        icon = Icons.bookmark;
        color = Colors.blue;
        break;
      case 'watching':
        icon = Icons.play_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.star;
        color = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 14,
        color: color,
      ),
    );
  }
}