import 'package:flutter/material.dart';
import '../theme/landing_theme.dart';

/// 2. Why Use The App Section (Clean White Background with 4 interactive feature cards).
class WhyAppSection extends StatelessWidget {
  const WhyAppSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 1200 ? 64 : (screenWidth > 600 ? 32 : 18),
        vertical: isDesktop ? 96 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: LandingTheme.blueIce,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0B3A8C).withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'WHY CHOOSE THE APP',
                  style: TextStyle(
                    color: Color(0xFF0B3A8C),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Headline: "HVAC Service, Simplified."
              const Text(
                'HVAC Service, Simplified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF061A3D),
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),

              // Description
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: const Text(
                  'From requesting a service to tracking your technician, the Al Taqwa app keeps your cooling service experience simple, transparent and connected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 56),

              // 4 Feature Cards Layout
              if (isDesktop)
                Row(
                  children: const [
                    Expanded(
                      child: _FeatureCard(
                        icon: Icons.touch_app_outlined,
                        title: 'Easy Service Booking',
                        description:
                            'Request installation, maintenance or repairs directly from your smartphone in seconds.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _FeatureCard(
                        icon: Icons.update_outlined,
                        title: 'Real-Time Updates',
                        description:
                            'Stay informed with instant alerts from initial request to technician dispatch and job completion.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _FeatureCard(
                        icon: Icons.badge_outlined,
                        title: 'Technician Assignment',
                        description:
                            'Know exactly when a certified technician is assigned to your villa or commercial facility.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _FeatureCard(
                        icon: Icons.history_edu_outlined,
                        title: 'Service History',
                        description:
                            'Keep an organized digital log of all your previous HVAC jobs, invoices and cooling maintenance.',
                      ),
                    ),
                  ],
                )
              else if (isTablet)
                Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.touch_app_outlined,
                            title: 'Easy Service Booking',
                            description:
                                'Request HVAC services directly from your phone.',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.update_outlined,
                            title: 'Real-Time Updates',
                            description:
                                'Stay updated throughout your service request.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.badge_outlined,
                            title: 'Technician Assignment',
                            description:
                                'Know when your service has been assigned to a technician.',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.history_edu_outlined,
                            title: 'Service History',
                            description:
                                'Keep track of your previous service requests.',
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: const [
                    _FeatureCard(
                      icon: Icons.touch_app_outlined,
                      title: 'Easy Service Booking',
                      description:
                          'Request HVAC services directly from your phone.',
                    ),
                    SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.update_outlined,
                      title: 'Real-Time Updates',
                      description:
                          'Stay updated throughout your service request.',
                    ),
                    SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.badge_outlined,
                      title: 'Technician Assignment',
                      description:
                          'Know when your service has been assigned to a technician.',
                    ),
                    SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.history_edu_outlined,
                      title: 'Service History',
                      description:
                          'Keep track of your previous service requests.',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? LandingTheme.gold
                : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF0B3A8C).withOpacity(0.14),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: LandingTheme.gold.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : LandingTheme.softCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container with gold accent border
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: _isHovered ? const Color(0xFF061A3D) : LandingTheme.blueIce,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered ? LandingTheme.gold : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: _isHovered ? LandingTheme.gold : const Color(0xFF0B3A8C),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Title
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFF061A3D),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              widget.description,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
