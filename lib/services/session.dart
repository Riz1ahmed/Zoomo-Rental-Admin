import 'package:shared_preferences/shared_preferences.dart';

/// Persists the admin username locally after a successful Firestore check so
/// the user stays signed in across app restarts. Logout clears it.
class Session {
  Session._();
  static final Session instance = Session._();

  static const _usernameKey = 'session_admin_username';

  String? adminUsername;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    adminUsername = prefs.getString(_usernameKey);
  }

  Future<void> login(String username) async {
    adminUsername = username;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<void> logout() async {
    adminUsername = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
  }

  bool get isLoggedIn => adminUsername != null;
}
