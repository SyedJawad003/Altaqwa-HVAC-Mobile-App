import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authErrorMessage(error));
    }
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authErrorMessage(error));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> saveUserProfile({
    required User user,
    required String name,
    required String email,
    String phone = '',
  }) async {
    try {
      final cleanName = name.trim();
      final normalizedEmail = email.trim().toLowerCase();
      await user.updateDisplayName(cleanName);
      await _firestore.collection('users').doc(user.uid).set({
        'name': cleanName,
        'email': normalizedEmail,
        'phone': phone.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw AuthException(_firestoreErrorMessage(error));
    }
  }

  Future<AuthUser> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (password.length < 6) {
      throw const AuthException('Weak Password: use at least 6 characters.');
    }

    try {
      final user = await signUp(
        email: normalizedEmail,
        password: password,
      );
      final cleanName = name.trim();
      final cleanPhone = phone.trim();

      await saveUserProfile(
        user: user,
        name: cleanName,
        email: normalizedEmail,
        phone: cleanPhone,
      );

      return AuthUser(
        name: cleanName,
        email: normalizedEmail,
        phone: cleanPhone,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_authErrorMessage(error));
    } on FirebaseException catch (error) {
      throw AuthException(_firestoreErrorMessage(error));
    }
  }

  Future<AuthUser> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = await signIn(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return await _readUser(user);
    } on AuthException {
      rethrow;
    }
  }

  Future<AuthUser?> checkAuthStatus() async {
    try {
      final user = _auth.currentUser;
      return user == null ? null : await _readUser(user);
    } on FirebaseException {
      return null;
    }
  }

  Future<AuthUser> _readUser(User user) async {
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data() ?? <String, dynamic>{};
    return AuthUser(
      name: data['name'] as String? ?? user.displayName ?? 'Friend',
      email: data['email'] as String? ?? user.email ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid credentials. Check your email and password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'weak-password':
        return 'Weak password. Use at least 6 characters.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _firestoreErrorMessage(FirebaseException error) =>
      error.code == 'permission-denied'
      ? 'Your account was created, but its profile could not be saved.'
      : 'Could not save your profile. Please try again.';
}
