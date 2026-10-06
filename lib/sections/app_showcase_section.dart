import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';
import '../widgets/airflow_painter.dart';
import '../widgets/phone_mockup.dart';

/// 4. Mobile App Showcase Section (5 Staggered Overlapping Phones + Feature Pills).
class AppShowcaseSection extends StatefulWidget {
  const AppShowcaseSection({super.key});

  @override
  State<AppShowcaseSection> createState() => _AppShowcaseSectionState();
}

class _AppShowcaseSectionState extends State<AppShowcaseSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  int _activeScreenIndex = 1; // Default to Dashboard

  final List<PhoneScreenType> _screens = const [
    PhoneScreenType.login,
    PhoneScreenType.dashboard,
    PhoneScreenType.booking,
    PhoneScreenType.tracking,
    PhoneScreenType.notifications,
  ];

  final List<String> _screenLabels = const [
    'Sign In & Register',
    'Customer Dashboard',
    'Service Booking',
    'Technician Tracking',
    'Live Notifications',
  ];

  final List<String> _featurePills = const [
    'Register / Login',
    'Request a Service',
    'Select Service Type',
    'Submit Request',
    'View Request Status',
    'View Assigned Technician',
    'Notifications',
    'Track Progress',
    'Service History',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return Container(
      decoration: const BoxDecoration(
        gradient: LandingTheme.heroGradient,
      ),
      child: AirflowBackground(
        baseColor: const Color(0xFF38BDF8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 1200 ? 48 : (screenWidth > 600 ? 24 : 16),
            vertical: isDesktop ? 96 : 64,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: LandingTheme.gold.withOpacity(0.5),
                      ),
                    ),
                    child: const Text(
                      'MOBILE APP SHOWCASE',
                      style: TextStyle(
                        color: LandingTheme.goldLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Headline: "Everything You Need.\nIn One App."
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        LandingTheme.goldTextGradient.createShader(bounds),
                    child: const Text(
                      'Everything You Need.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  const Text(
                    'In One App.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subheadline
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Engineered for speed and transparency, the Al Taqwa application puts complete climate comfort and technician management in your pocket.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 52),

                  // Phone Mockups Presentation
                  if (isDesktop)
                    _buildDesktopOverlappingPhones()
                  else
                    _buildMobileInteractiveShowcase(screenWidth),

                  const SizedBox(height: 48),

                  // Feature Pills
                  const Text(
                    'APP CAPABILITIES',
                    style: TextStyle(
                      color: LandingTheme.gold,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _featurePills.map((pill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: LandingTheme.gold,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pill,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 36),

                  // Download prompt button
                  ElevatedButton.icon(
                    onPressed: () => openCustomerPanel(context),
                    icon: const Icon(Icons.arrow_forward,
                        color: Color(0xFF061A3D), size: 16),
                    label: const Text(
                      'Access Customer Panel Online',
                      style: TextStyle(
                        color: Color(0xFF061A3D),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LandingTheme.gold,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  /// 5 Overlapping Staggered Phones on Wide Screens
  Widget _buildDesktopOverlappingPhones() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final float = math.sin(_waveController.value * 2 * math.pi);

        return Center(
          child: SizedBox(
            height: 600,
            width: 1180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Far Left Phone (Login)
                Positioned(
                  left: 30,
                  top: 80 + float * 6,
                  child: Opacity(
                    opacity: 0.85,
                    child: Transform.rotate(
                      angle: -0.06,
                      child: const PhoneMockup(
                        screenType: PhoneScreenType.login,
                        scale: 0.74,
                      ),
                    ),
                  ),
                ),

                // 2. Mid Left Phone (Booking)
                Positioned(
                  left: 220,
                  top: 45 - float * 8,
                  child: Opacity(
                    opacity: 0.94,
                    child: Transform.rotate(
                      angle: -0.03,
                      child: const PhoneMockup(
                        screenType: PhoneScreenType.booking,
                        scale: 0.82,
                      ),
                    ),
                  ),
                ),

                // 4. Mid Right Phone (Tracking)
                Positioned(
                  right: 220,
                  top: 45 - float * 7,
                  child: Opacity(
                    opacity: 0.94,
                    child: Transform.rotate(
                      angle: 0.03,
                      child: const PhoneMockup(
                        screenType: PhoneScreenType.tracking,
                        scale: 0.82,
                      ),
                    ),
                  ),
                ),

                // 5. Far Right Phone (Notifications)
                Positioned(
                  right: 30,
                  top: 80 + float * 6,
                  child: Opacity(
                    opacity: 0.85,
                    child: Transform.rotate(
                      angle: 0.06,
                      child: const PhoneMockup(
                        screenType: PhoneScreenType.notifications,
                        scale: 0.74,
                      ),
                    ),
                  ),
                ),

                // 3. Center Dominant Phone (Customer Dashboard)
                Positioned(
                  top: 15 + float * 10,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: LandingTheme.gold.withOpacity(0.2),
                          blurRadius: 50,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const PhoneMockup(
                      screenType: PhoneScreenType.dashboard,
                      scale: 0.92,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mobile & Tablet Showcase with Screen Selector Tab
  Widget _buildMobileInteractiveShowcase(double screenWidth) {
    return Column(
      children: [
        // Screen Tab Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_screens.length, (index) {
              final active = _activeScreenIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _activeScreenIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? LandingTheme.gold : Colors.white12,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _screenLabels[index],
                    style: TextStyle(
                      color: active ? const Color(0xFF061A3D) : Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // Display Active Phone Mockup
        Center(
          child: PhoneMockup(
            screenType: _screens[_activeScreenIndex],
            scale: screenWidth < 450 ? 0.82 : 0.88,
          ),
        ),
      ],
    );
  }
}
