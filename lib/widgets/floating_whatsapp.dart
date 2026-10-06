import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';

/// Floating WhatsApp chat action button with pulse animation.
class FloatingWhatsAppButton extends StatefulWidget {
  const FloatingWhatsAppButton({super.key});

  @override
  State<FloatingWhatsAppButton> createState() => _FloatingWhatsAppButtonState();
}

class _FloatingWhatsAppButtonState extends State<FloatingWhatsAppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 26,
      right: 26,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = _isHovered ? 1.12 : _scaleAnimation.value;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => openWhatsApp(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF061A3D),
                    Color(0xFF0B3A8C),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: LandingTheme.gold,
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF061A3D).withOpacity(0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: LandingTheme.gold.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: LandingTheme.gold,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Chat on WhatsApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
