// main.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'favorite_page.dart';
import 'history_page.dart';
import 'login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnimeApp());
}

class AnimeApp extends StatelessWidget {
  const AnimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E88E5),
        useMaterial3: false,
      ),
      home: const SplashOrMain(),
    );
  }
}

/// SplashOrMain - checks auth state and shows appropriate screen
class SplashOrMain extends StatefulWidget {
  const SplashOrMain({super.key});

  @override
  State<SplashOrMain> createState() => _SplashOrMainState();
}

class _SplashOrMainState extends State<SplashOrMain> {
  final AuthService _auth = AuthService();
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      final isLogged = await _auth.isLoggedIn();
      if (mounted) {
        setState(() {
          _loggedIn = isLogged;
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loggedIn = false;
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
        ),
      );
    }
    return _loggedIn ? const MainPage() : const LoginPage();
  }
}

/// MainPage with BottomNavigation
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Make sure these pages exist in your lib folder.
  final List<Widget> _pages = const [
    // HomePage should be a StatefulWidget that loads anime grid
    HomePage(),
    // Provide basic placeholders for now; replace with your real pages
    FavoritesPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
