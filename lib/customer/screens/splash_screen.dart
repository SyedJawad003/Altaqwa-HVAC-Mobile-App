import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_gate.dart';
import '../widgets/app_page_route.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _entrance;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    final curve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _entrance = curve;
    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );
    _routeUser();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  Future<void> _routeUser() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(appPageRoute<void>(const AuthGate()));
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
          child: FadeTransition(
            opacity: _entrance,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(_entrance),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: Container(
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
                        'assets/altaqwa_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, error, stackTrace) => const Icon(
                          Icons.ac_unit,
                          color: goldLight,
                          size: 52,
                        ),
                      ),
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
                    child: CircularProgressIndicator(
                      color: gold,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
