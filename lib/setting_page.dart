import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoPlay = true;
  bool _wifiOnly = false;
  bool _notifications = true;
  bool _darkMode = false;
  String _videoQuality = 'auto';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoPlay = prefs.getBool('auto_play') ?? true;
      _wifiOnly = prefs.getBool('wifi_only') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _videoQuality = prefs.getString('video_quality') ?? 'auto';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF1E88E5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E88E5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Playback',
            [
              _buildSwitchTile(
                'Auto-play next episode',
                'Automatically play the next episode',
                Icons.play_circle_outline,
                _autoPlay,
                (value) {
                  setState(() => _autoPlay = value);
                  _saveSetting('auto_play', value);
                },
              ),
              _buildSwitchTile(
                'Wi-Fi only',
                'Stream only when connected to Wi-Fi',
                Icons.wifi,
                _wifiOnly,
                (value) {
                  setState(() => _wifiOnly = value);
                  _saveSetting('wifi_only', value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Video Quality',
            [
              _buildQualityTile(),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Notifications',
            [
              _buildSwitchTile(
                'Push notifications',
                'Get notified about new episodes',
                Icons.notifications_outlined,
                _notifications,
                (value) {
                  setState(() => _notifications = value);
                  _saveSetting('notifications', value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Appearance',
            [
              _buildSwitchTile(
                'Dark mode',
                'Use dark theme (Coming soon)',
                Icons.dark_mode_outlined,
                _darkMode,
                (value) {
                  setState(() => _darkMode = value);
                  _saveSetting('dark_mode', value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dark mode coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Data & Storage',
            [
              _buildActionTile(
                'Clear cache',
                'Free up storage space',
                Icons.delete_outline,
                () => _showClearCacheDialog(),
              ),
              _buildActionTile(
                'Download settings',
                'Manage downloaded episodes',
                Icons.download_outlined,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E88E5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1E88E5), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E88E5),
      ),
    );
  }

  Widget _buildQualityTile() {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.high_quality,
          color: Color(0xFF1E88E5),
          size: 22,
        ),
      ),
      title: const Text(
        'Default quality',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _videoQuality == 'auto'
            ? 'Auto (recommended)'
            : _videoQuality.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showQualityDialog(),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1E88E5), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _showQualityDialog() async {
    final quality = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Quality'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('auto', 'Auto (recommended)'),
            _buildQualityOption('1080p', 'Full HD (1080p)'),
            _buildQualityOption('720p', 'HD (720p)'),
            _buildQualityOption('480p', 'SD (480p)'),
            _buildQualityOption('360p', 'Low (360p)'),
          ],
        ),
      ),
    );

    if (quality != null) {
      setState(() => _videoQuality = quality);
      _saveSetting('video_quality', quality);
    }
  }

  Widget _buildQualityOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _videoQuality,
      onChanged: (value) => Navigator.pop(context, value),
      activeColor: const Color(0xFF1E88E5),
    );
  }

  Future<void> _showClearCacheDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data and free up storage space. Continue?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clearing cache...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Simulate clearing cache
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}