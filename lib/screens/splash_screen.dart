import 'package:flutter/material.dart';

import '../services/auth_gate.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeUser();
  }

  Future<void> _routeUser() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/bg_img.png',
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) =>
              Container(decoration: BoxDecoration(gradient: navyGradient)),
        ),
        Container(color: navyDeep.withValues(alpha: 0.58)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.22),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/altaqwa logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stackTrace) =>
                      const Icon(Icons.ac_unit, color: goldLight, size: 52),
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                  children: [
                    TextSpan(
                      text: 'AL-',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'TAQWA',
                      style: TextStyle(color: goldLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'COMFORT SYSTEMS. DONE RIGHT.',
                style: TextStyle(
                  color: steel,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 38),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: gold, strokeWidth: 2),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
