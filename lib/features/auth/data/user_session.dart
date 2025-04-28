class UserSession {
  static Map<String, dynamic>? _currentUser;
  static String? _token;

  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get token => _token;

  static void setUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  static void setToken(String token) {
    _token = token;
  }

  static void clear() {
    _currentUser = null;
    _token = null;
  }

  static bool get isAuthenticated => _token != null;

  static String? get role => _currentUser?['role'];
  static String? get fullName => _currentUser?['fullName'];
  static String get initials {
    final name = fullName ?? '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
