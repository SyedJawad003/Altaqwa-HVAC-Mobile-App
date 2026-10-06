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
    required this.role,
  });
  final String name;
  final String email;
  final String phone;
  final String role;
}

class AuthService {
  static const String adminEmail = 'admin@altaqwa.com';
  static const String adminPassword = 'admin123';

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> ensureAdminAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email?.trim().toLowerCase() == adminEmail) {
        await _firestore.collection('admins').doc(user.uid).  set({
          'uid': user.uid,
          'email': adminEmail,
          'name': 'Al Taqwa Administrator',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      await _firestore.collection('admins').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': adminEmail,
        'name': 'Al Taqwa Administrator',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        return;
      }
      if (error.code == 'operation-not-allowed') {
        throw AuthException('Firebase Email/Password authentication is not enabled in the project.');
      }
      throw AuthException(_authErrorMessage(error));
    } on FirebaseException catch (error) {
      throw AuthException(_firestoreErrorMessage(error));
    }
  }

  Future<bool> isAdminUser(User user) async {
    final email = user.email?.trim().toLowerCase();
    if (email == adminEmail) return true;

    try {
      final adminSnapshot = await _firestore.collection('admins').doc(user.uid).get();
      if (adminSnapshot.exists) {
        final role = (adminSnapshot.data()?['role'] as String? ?? '').trim().toLowerCase();
        if (role == 'admin') return true;
      }

      final userSnapshot = await _firestore.collection('users').doc(user.uid).get();
      final userRole = (userSnapshot.data()?['role'] as String? ?? '').trim().toLowerCase();
      if (userRole == 'admin') return true;
    } on FirebaseException {
      return email == adminEmail;
    }

    return false;
  }

  Future<void> saveAdminProfile({
    required User user,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('admins').doc(user.uid).set({
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

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
    final normalizedEmail = email.trim().toLowerCase();
    try {
      if (normalizedEmail == adminEmail && password == adminPassword) {
        await ensureAdminAccount();
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (error) {
      if (normalizedEmail == adminEmail && password == adminPassword) {
        await ensureAdminAccount();
        final credential = await _auth.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        return credential.user!;
      }
      throw AuthException(_authErrorMessage(error));
    } on FirebaseException catch (error) {
      throw AuthException(_firestoreErrorMessage(error));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> saveUserProfile({
    required User user,
    required String name,
    required String email,
    String phone = '',
    String role = 'customer',
  }) async {
    try {
      await user.reload();
      await user.getIdToken(true);
      final cleanName = name.trim();
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedRole = role.trim().toLowerCase();
      await user.updateDisplayName(cleanName);
      final profile = {
        'uid': user.uid,
        'name': cleanName,
        'email': normalizedEmail,
        'phone': phone.trim(),
        'role': normalizedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (normalizedRole == 'technician') {
        await _firestore.collection('technicians').doc(user.uid).set({
          ...profile,
          'available': true,
          'status': 'active',
        }, SetOptions(merge: true));
      } else if (normalizedRole == 'supervisor') {
        await _firestore.collection('supervisors').doc(user.uid).set({
          ...profile,
          'authUid': user.uid,
          'status': 'active',
        }, SetOptions(merge: true));
      } else {
        await _firestore.collection('users').doc(user.uid).set(profile, SetOptions(merge: true));
      }
    } on FirebaseException catch (error) {
      throw AuthException(_firestoreErrorMessage(error));
    }
  }

  Future<AuthUser> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (password.length < 6) {
      throw const AuthException('Weak Password: use at least 6 characters.');
    }

    try {
      User user;
      try {
        user = await signUp(
          email: normalizedEmail,
          password: password,
        );
      } on AuthException catch (error) {
        if (!error.message.toLowerCase().contains('already in use')) {
          rethrow;
        }
        user = await signIn(email: normalizedEmail, password: password);
      }
      final cleanName = name.trim();
      final cleanPhone = phone.trim();

      await saveUserProfile(
        user: user,
        name: cleanName,
        email: normalizedEmail,
        phone: cleanPhone,
        role: role,
      );

      return AuthUser(
        name: cleanName,
        email: normalizedEmail,
        phone: cleanPhone,
        role: role.trim().toLowerCase(),
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

  Future<AuthUser> readUserForRouting(User user) => _readUser(user);

  Future<AuthUser> _readUser(User user) async {
    final collections = ['supervisors', 'technicians', 'admins', 'users'];
    for (final collection in collections) {
      try {
        final snapshot = await _firestore.collection(collection).doc(user.uid).get();
        if (!snapshot.exists) continue;
        final data = snapshot.data() ?? <String, dynamic>{};
        final storedRole = (data['role'] as String?)?.trim().toLowerCase();
        final inferred = switch (collection) {
          'supervisors' => 'supervisor',
          'technicians' => 'technician',
          'admins' => 'admin',
          _ => 'customer',
        };
        return AuthUser(
          name: data['name'] as String? ?? user.displayName ?? 'Friend',
          email: data['email'] as String? ?? user.email ?? '',
          phone: data['phone'] as String? ?? '',
          role: (storedRole == null || storedRole.isEmpty) ? inferred : storedRole,
        );
      } on FirebaseException {
        continue;
      }
    }
    return AuthUser(
      name: user.displayName ?? 'Friend',
      email: user.email ?? '',
      phone: '',
      role: 'customer',
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
