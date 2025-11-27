import 'package:flutter/material.dart';
import 'main.dart' as main_file;
import 'home_page.dart';
import 'anime_detail_page.dart';
import 'episode_player_page.dart';
import 'history_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'setting_page.dart';

/// App Routes Configuration
/// Centralized routing to avoid circular imports
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String animeDetail = '/anime-detail';
  static const String episodePlayer = '/episode-player';
  static const String history = '/history';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String settings = '/settings';

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const main_file.SplashScreen());

      case login:
        return _buildRoute(const main_file.LoginPage());

      case home:
        return _buildRoute(const HomePage());

      case history:
        return _buildRoute(const HistoryPage());

      case favorites:
        return _buildRoute(const FavoritesPage());

      case profile:
        return _buildRoute(const ProfilePage());

      case search:
        return _buildRoute(const SearchPage());

      case animeDetail:
        return _buildRoute(const SettingsPage());

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Build route with transition
  static Route _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Navigate to route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Replace current route
  static Future<Future> navigateReplace<T>(
      BuildContext context, String routeName,
      {Object? arguments}) async {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Go back
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }
}
