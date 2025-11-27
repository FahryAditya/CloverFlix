import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
    // Add your OAuth client ID here
    // clientId: 'YOUR_OAUTH_CLIENT_ID.apps.googleusercontent.com',
  );
  final ApiService _apiService = ApiService();

  /// Sign in with Google - Fixed version
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Sign out first to ensure fresh login
      await _googleSignIn.signOut();
      
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        // User cancelled the sign-in
        return {
          'success': false,
          'message': 'Login cancelled by user',
        };
      }

      // Get authentication details
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;

      if (idToken == null) {
        return {
          'success': false,
          'message': 'Failed to get ID token',
        };
      }

      debugPrint('✅ Google Sign-In successful');
      debugPrint('User: ${account.email}');
      debugPrint('ID Token: ${idToken.substring(0, 20)}...');

      // Send ID token to backend
      final response = await _apiService.loginWithGoogle(idToken);

      if (response['success'] == true) {
        final token = response['token'] ?? response['jwt'] ?? '';
        
        if (token.isNotEmpty) {
          // Save user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          await prefs.setString('user_email', account.email);
          await prefs.setString('user_name', account.displayName ?? '');
          await prefs.setString('user_photo', account.photoUrl ?? '');
          await prefs.setString('user_id', account.id);
          
          // Save Google tokens for future use
          if (accessToken != null) {
            await prefs.setString('google_access_token', accessToken);
          }
          await prefs.setString('google_id_token', idToken);
          
          debugPrint('✅ Login successful, token saved');
          
          return {
            'success': true,
            'message': 'Login successful',
            'user': {
              'email': account.email,
              'name': account.displayName,
              'photo': account.photoUrl,
              'id': account.id,
            },
          };
        }
      }

      // If backend fails, still allow demo mode
      if (kDebugMode) {
        debugPrint('⚠️ Backend login failed, using demo mode');
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', 'demo_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString('user_email', account.email);
        await prefs.setString('user_name', account.displayName ?? '');
        await prefs.setString('user_photo', account.photoUrl ?? '');
        await prefs.setBool('demo_mode', true);
        
        return {
          'success': true,
          'message': 'Login successful (Demo Mode)',
          'demo_mode': true,
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Login failed',
      };
    } catch (e) {
      debugPrint('❌ Error signing in with Google: $e');
      
      // Demo mode fallback for development
      if (kDebugMode) {
        debugPrint('⚠️ Using demo mode due to error');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', 'demo_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString('user_email', 'demo@example.com');
        await prefs.setString('user_name', 'Demo User');
        await prefs.setBool('demo_mode', true);
        
        return {
          'success': true,
          'message': 'Demo mode activated',
          'demo_mode': true,
        };
      }
      
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
    }
  }

  /// Get JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Get user info
  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'name': prefs.getString('user_name'),
      'photo': prefs.getString('user_photo'),
      'id': prefs.getString('user_id'),
    };
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if in demo mode
  Future<bool> isDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('demo_mode') ?? false;
  }

  /// Refresh Google token if expired
  Future<bool> refreshToken() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.idToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('google_id_token', auth.idToken!);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  /// Get current Google account
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
  }
}
