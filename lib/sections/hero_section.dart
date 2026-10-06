import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';
import '../widgets/airflow_painter.dart';
import '../widgets/glass_card.dart';
import '../widgets/phone_mockup.dart';

/// 1. Hero Section with 3 floating realistic phone mockups, status chips & HVAC airflow.
class HeroSection extends StatefulWidget {
  final VoidCallback onExploreServices;

  const HeroSection({
    super.key,
    required this.onExploreServices,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnim1;
  late final Animation<double> _floatAnim2;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnim1 = Tween<double>(begin: -10.0, end: 12.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _floatAnim2 = Tween<double>(begin: 8.0, end: -10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      decoration: const BoxDecoration(
        gradient: LandingTheme.heroGradient,
      ),
      child: AirflowBackground(
        child: Container(
          constraints: const BoxConstraints(minHeight: 720),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 1200 ? 64 : (screenWidth > 600 ? 32 : 18),
            vertical: isDesktop ? 96 : 56,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Copy
                        Expanded(
                          flex: 11,
                          child: _buildLeftCopy(context),
                        ),
                        const SizedBox(width: 48),
                        // Right Mockup Showcase
                        Expanded(
                          flex: 13,
                          child: _buildRightMockups(context, isDesktop: true),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildLeftCopy(context, centerText: true),
                        const SizedBox(height: 52),
                        _buildRightMockups(context, isDesktop: false),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftCopy(BuildContext context, {bool centerText = false}) {
    return Column(
      crossAxisAlignment:
          centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: LandingTheme.gold.withOpacity(0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: LandingTheme.gold.withOpacity(0.12),
                blurRadius: 12,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.ac_unit, color: LandingTheme.gold, size: 14),
              SizedBox(width: 8),
              Text(
                'AL TAQWA MOBILE APP',
                style: TextStyle(
                  color: LandingTheme.goldLight,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Main Headline: "Your Cooling. Our Care." (second line in gold)
        Column(
          crossAxisAlignment:
              centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Cooling.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) =>
                  LandingTheme.goldTextGradient.createShader(bounds),
              child: const Text(
                'Our Care.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Supporting Headline
        Text(
          'Professional AC services, right at your fingertips.',
          textAlign: centerText ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),

        // Description
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(
            'Book, manage and track your air conditioning services with the Al Taqwa mobile app. Get reliable HVAC support whenever you need it.',
            textAlign: centerText ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 15.5,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Action Buttons
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: centerText ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _HeroPrimaryButton(
              title: 'Download the App',
              onTap: () => openCustomerPanel(context),
            ),
            _HeroSecondaryButton(
              title: 'Explore Services',
              onTap: widget.onExploreServices,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // UAE Trust indicators
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, color: LandingTheme.gold, size: 18),
            const SizedBox(width: 8),
            Text(
              'Official Al Taqwa Mobile Platform • United Arab Emirates',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightMockups(BuildContext context, {required bool isDesktop}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = screenWidth < 500 ? 0.72 : (isDesktop ? 0.88 : 0.80);

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: isDesktop ? 600 : math.min(screenWidth - 32, 540),
            height: isDesktop ? 620 : 490,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Ambient Blue/Gold Glow behind phones
                Positioned(
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B3A8C).withOpacity(0.5),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                        BoxShadow(
                          color: LandingTheme.gold.withOpacity(0.16),
                          blurRadius: 80,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),

                // Back Phone Left (Login / Register)
                Positioned(
                  left: isDesktop ? 20 : 0,
                  top: isDesktop ? 40 + _floatAnim2.value : 20 + _floatAnim2.value,
                  child: Opacity(
                    opacity: 0.88,
                    child: PhoneMockup(
                      screenType: PhoneScreenType.login,
                      scale: scaleFactor * 0.9,
                    ),
                  ),
                ),

                // Back Phone Right (Notifications)
                Positioned(
                  right: isDesktop ? 20 : 0,
                  top: isDesktop ? 55 + _floatAnim2.value : 35 + _floatAnim2.value,
                  child: Opacity(
                    opacity: 0.88,
                    child: PhoneMockup(
                      screenType: PhoneScreenType.notifications,
                      scale: scaleFactor * 0.9,
                    ),
                  ),
                ),

                // Center Dominant Phone (Customer Dashboard)
                Positioned(
                  top: 10 + _floatAnim1.value,
                  child: PhoneMockup(
                    screenType: PhoneScreenType.dashboard,
                    scale: scaleFactor,
                  ),
                ),

                // Floating Notification Cards Around Mockups
                // 1. Service Request Received
                Positioned(
                  top: isDesktop ? 12 : 4,
                  left: isDesktop ? 0 : 8,
                  child: _FloatingChip(
                    icon: Icons.assignment_turned_in,
                    text: 'Service Request Received',
                    subtext: 'ID #AT-8842 Logged',
                    color: LandingTheme.gold,
                  ),
                ),

                // 2. Technician Assigned
                Positioned(
                  top: isDesktop ? 140 : 110,
                  right: isDesktop ? -10 : 4,
                  child: _FloatingChip(
                    icon: Icons.engineering,
                    text: 'Technician Assigned',
                    subtext: 'Tariq M. Dispatched',
                    color: const Color(0xFF38BDF8),
                  ),
                ),

                // 3. Job In Progress
                Positioned(
                  bottom: isDesktop ? 110 : 80,
                  left: isDesktop ? -15 : 6,
                  child: _FloatingChip(
                    icon: Icons.sync,
                    text: 'Job In Progress',
                    subtext: 'Pressure & Coil Check',
                    color: const Color(0xFF60A5FA),
                  ),
                ),

                // 4. Service Completed
                Positioned(
                  bottom: isDesktop ? 18 : 6,
                  right: isDesktop ? 15 : 12,
                  child: _FloatingChip(
                    icon: Icons.check_circle,
                    text: 'Service Completed',
                    subtext: 'Efficiency 100% Verified',
                    color: LandingTheme.statusSuccess,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;
  final Color color;

  const _FloatingChip({
    required this.icon,
    required this.text,
    required this.subtext,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 14,
      borderColor: color.withOpacity(0.4),
      backgroundColor: const Color(0xFF040E22).withOpacity(0.85),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                ),
              ),
              Text(
                subtext,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPrimaryButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _HeroPrimaryButton({required this.title, required this.onTap});

  @override
  State<_HeroPrimaryButton> createState() => _HeroPrimaryButtonState();
}

class _HeroPrimaryButtonState extends State<_HeroPrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          decoration: BoxDecoration(
            gradient: LandingTheme.goldGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: LandingTheme.gold.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: LandingTheme.gold.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.download_rounded,
                  color: Color(0xFF061A3D), size: 20),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFF061A3D),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSecondaryButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _HeroSecondaryButton({required this.title, required this.onTap});

  @override
  State<_HeroSecondaryButton> createState() => _HeroSecondaryButtonState();
}

class _HeroSecondaryButtonState extends State<_HeroSecondaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? Colors.white : Colors.white.withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_downward, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
