import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';

/// 3. Professional HVAC Cooling Services Section
class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 680 && screenWidth < 1024;

    return Container(
      color: LandingTheme.blueSoftBg,
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
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0B3A8C).withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'EXPERT COOLING SOLUTIONS',
                  style: TextStyle(
                    color: Color(0xFF0B3A8C),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Headline: "Professional Cooling Services"
              const Text(
                'Professional Cooling Services',
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
                constraints: const BoxConstraints(maxWidth: 640),
                child: const Text(
                  'Comprehensive HVAC engineering for residential villas, apartments and commercial facilities across the UAE.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 52),

              // 6 Service Cards Grid (Desktop 3x2, Tablet 2x3, Mobile 1x6)
              if (isDesktop)
                Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: _ServiceCard(
                            title: 'AC Installation',
                            description:
                                'Precision installation of ducted split, central and VRF systems engineered for optimal UAE thermal performance.',
                            icon: Icons.settings_system_daydream,
                            isFeatured: false,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _ServiceCard(
                            title: 'AC Repair',
                            description:
                                'Rapid diagnostics and reliable repair for cooling loss, compressor failure, gas leakages and electrical faults.',
                            icon: Icons.build_circle_outlined,
                            isFeatured: true, // Rich blue gradient card
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _ServiceCard(
                            title: 'AC Maintenance',
                            description:
                                'Comprehensive filter deep-cleaning, evaporator wash, drain flushing and refrigerant pressure calibration.',
                            icon: Icons.cleaning_services_outlined,
                            isFeatured: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Expanded(
                          child: _ServiceCard(
                            title: 'HVAC Services',
                            description:
                                'Complete climate control management, air ductwork inspection, thermostat calibration and ventilation testing.',
                            icon: Icons.air,
                            isFeatured: false,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _ServiceCard(
                            title: 'Preventive Maintenance',
                            description:
                                'Scheduled seasonal service contracts that prevent sudden breakdowns, maximize airflow and cut power costs.',
                            icon: Icons.shield_outlined,
                            isFeatured: false,
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _ServiceCard(
                            title: 'Cooling System Inspection',
                            description:
                                'Detailed multi-point thermodynamic diagnostics, thermal imaging, duct leakage audits and efficiency checks.',
                            icon: Icons.fact_check_outlined,
                            isFeatured: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else if (isTablet)
                Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: _ServiceCard(
                            title: 'AC Installation',
                            description:
                                'Precision installation of ducted split, central and VRF systems engineered for optimal UAE thermal performance.',
                            icon: Icons.settings_system_daydream,
                            isFeatured: false,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _ServiceCard(
                            title: 'AC Repair',
                            description:
                                'Rapid diagnostics and reliable repair for cooling loss, compressor failure, gas leakages and electrical faults.',
                            icon: Icons.build_circle_outlined,
                            isFeatured: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(
                          child: _ServiceCard(
                            title: 'AC Maintenance',
                            description:
                                'Comprehensive filter deep-cleaning, evaporator wash, drain flushing and refrigerant pressure calibration.',
                            icon: Icons.cleaning_services_outlined,
                            isFeatured: false,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _ServiceCard(
                            title: 'HVAC Services',
                            description:
                                'Complete climate control management, air ductwork inspection, thermostat calibration and ventilation testing.',
                            icon: Icons.air,
                            isFeatured: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(
                          child: _ServiceCard(
                            title: 'Preventive Maintenance',
                            description:
                                'Scheduled seasonal service contracts that prevent sudden breakdowns, maximize airflow and cut power costs.',
                            icon: Icons.shield_outlined,
                            isFeatured: false,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _ServiceCard(
                            title: 'Cooling System Inspection',
                            description:
                                'Detailed multi-point thermodynamic diagnostics, thermal imaging, duct leakage audits and efficiency checks.',
                            icon: Icons.fact_check_outlined,
                            isFeatured: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: const [
                    _ServiceCard(
                      title: 'AC Installation',
                      description:
                          'Precision installation of ducted split and central units.',
                      icon: Icons.settings_system_daydream,
                      isFeatured: false,
                    ),
                    SizedBox(height: 16),
                    _ServiceCard(
                      title: 'AC Repair',
                      description:
                          'Rapid diagnostics and reliable repair for cooling loss and leaks.',
                      icon: Icons.build_circle_outlined,
                      isFeatured: true,
                    ),
                    SizedBox(height: 16),
                    _ServiceCard(
                      title: 'AC Maintenance',
                      description:
                          'Deep coil cleaning, filter sanitize and gas check.',
                      icon: Icons.cleaning_services_outlined,
                      isFeatured: false,
                    ),
                    SizedBox(height: 16),
                    _ServiceCard(
                      title: 'HVAC Services',
                      description:
                          'Complete climate control and airflow management.',
                      icon: Icons.air,
                      isFeatured: false,
                    ),
                    SizedBox(height: 16),
                    _ServiceCard(
                      title: 'Preventive Maintenance',
                      description:
                          'Scheduled cooling checkups to avert unexpected breakdowns.',
                      icon: Icons.shield_outlined,
                      isFeatured: false,
                    ),
                    SizedBox(height: 16),
                    _ServiceCard(
                      title: 'Cooling System Inspection',
                      description:
                          'Multi-point diagnostic inspection for maximum efficiency.',
                      icon: Icons.fact_check_outlined,
                      isFeatured: false,
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

class _ServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isFeatured;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isFeatured,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isFeatured;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => openCustomerPanel(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -7 : 0, 0),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF061A3D),
                      Color(0xFF0B3A8C),
                      Color(0xFF14479E),
                    ],
                  )
                : null,
            color: isDark ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? LandingTheme.gold
                  : (isDark
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFFE2E8F0)),
              width: _isHovered ? 1.6 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (isDark
                              ? const Color(0xFF0B3A8C)
                              : LandingTheme.gold)
                          .withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : LandingTheme.softCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : LandingTheme.blueIce,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? LandingTheme.gold.withOpacity(0.6)
                        : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: isDark ? LandingTheme.gold : const Color(0xFF0B3A8C),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                widget.title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF061A3D),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                widget.description,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.78)
                      : const Color(0xFF64748B),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Learn More Interaction Link
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Book Service',
                    style: TextStyle(
                      color: isDark ? LandingTheme.goldLight : const Color(0xFF0B3A8C),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: isDark
                          ? LandingTheme.goldLight
                          : const Color(0xFF0B3A8C),
                    ),
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
