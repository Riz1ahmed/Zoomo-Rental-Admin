/// Minimal in-memory session. Since there's no Firebase Auth, "logged in"
/// just means this app instance verified credentials against Firestore
/// once. Good enough for a single-admin internal tool.
class Session {
  Session._();
  static final Session instance = Session._();

  bool isLoggedIn = false;
  String? adminUsername;

  void login(String username) {
    isLoggedIn = true;
    adminUsername = username;
  }

  void logout() {
    isLoggedIn = false;
    adminUsername = null;
  }
}
