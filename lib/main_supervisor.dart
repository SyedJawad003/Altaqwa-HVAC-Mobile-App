import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'supervisor/supervisor_login_screen.dart';
import 'supervisor/supervisor_widgets.dart';

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

  runApp(SupervisorApp(initializationError: initializationError));
}

class SupervisorApp extends StatelessWidget {
  const SupervisorApp({super.key, this.initializationError});

  final Object? initializationError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Taqwa Supervisor App',
      debugShowCheckedModeBanner: false,
      theme: supervisorTheme,
      home: initializationError == null
          ? const SupervisorLoginScreen()
          : _SupervisorInitializationError(error: initializationError!),
    );
  }
}

class _SupervisorInitializationError extends StatelessWidget {
  const _SupervisorInitializationError({required this.error});

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
