import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthUser {
  const AuthUser({
    required this.name,
    required this.email,
    required this.phone,
  });
  final String name;
  final String email;
  final String phone;
}

class AuthService {
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';
  static const _phoneKey = 'auth_phone';
  static const _passwordKey = 'auth_password';
  static const _sessionKey = 'auth_session';

  Future<AuthUser> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    if (password.length < 6) {
      throw const AuthException('Weak Password: use at least 6 characters.');
    }
    if (preferences.getString(_emailKey) != null) {
      throw const AuthException('Email already in use.');
    }
    await preferences.setString(_nameKey, name.trim());
    await preferences.setString(_emailKey, normalizedEmail);
    await preferences.setString(_phoneKey, phone.trim());
    await preferences.setString(_passwordKey, password);
    await preferences.setBool(_sessionKey, true);
    return AuthUser(
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
    );
  }

  Future<AuthUser> loginUser({
    required String email,
    required String password,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(_emailKey) != email.trim().toLowerCase() ||
        preferences.getString(_passwordKey) != password) {
      throw const AuthException(
        'Invalid Credentials. Check your email and password.',
      );
    }
    await preferences.setBool(_sessionKey, true);
    return _readUser(preferences);
  }

  Future<AuthUser?> checkAuthStatus() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_sessionKey) == true
        ? _readUser(preferences)
        : null;
  }

  AuthUser _readUser(SharedPreferences preferences) => AuthUser(
    name: preferences.getString(_nameKey) ?? 'Friend',
    email: preferences.getString(_emailKey) ?? '',
    phone: preferences.getString(_phoneKey) ?? '',
  );
}
