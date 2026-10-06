import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import 'auth_service.dart';
import 'role_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.authStateChanges});

  final Stream<User?>? authStateChanges;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authStateChanges ?? FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<AuthUser>(
          future: AuthService().readUserForRouting(user),
          builder: (context, profileSnapshot) {
            if (!profileSnapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            return appHomeForRole(profileSnapshot.data!.role);
          },
        );
      },
    );
  }
}
