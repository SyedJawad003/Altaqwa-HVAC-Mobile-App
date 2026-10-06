import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'admin/admin_theme.dart';
import 'admin/admin_web_login_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initializationError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
  } catch (error) {
    initializationError = error;
  }
  runApp(AdminApp(initializationError: initializationError));
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key, this.initializationError});

  final Object? initializationError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Taqwa Admin Web App',
      debugShowCheckedModeBanner: false,
      theme: adminWebTheme,
      home: initializationError == null
          ? const AdminWebLoginScreen()
          : _AdminInitializationError(error: initializationError!),
    );
  }
}

class _AdminInitializationError extends StatelessWidget {
  const _AdminInitializationError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  color: Colors.red,
                  size: 42,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Firebase could not start',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => main(),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}