import 'package:flutter/material.dart';
import '../theme/landing_theme.dart';
import '../widgets/glass_card.dart';

/// 8. Why Al Taqwa / Trust Section (Deep blue background with glass cards).
/// Note: No invented statistics or numerical claims used.
class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    return Container(
      decoration: const BoxDecoration(
        gradient: LandingTheme.blueSectionGradient,
      ),
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
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: LandingTheme.gold.withOpacity(0.5),
                  ),
                ),
                child: const Text(
                  'WHY AL TAQWA',
                  style: TextStyle(
                    color: LandingTheme.goldLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Headline: "Reliable Cooling.\nProfessional Service."
              const Text(
                'Reliable Cooling.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) =>
                    LandingTheme.goldTextGradient.createShader(bounds),
                child: const Text(
                  'Professional Service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'Dedicated to delivering uninterrupted air conditioning comfort for homes, villas and businesses across the UAE.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 56),

              // 4 Pillar Cards
              if (isDesktop)
                Row(
                  children: const [
                    Expanded(
                      child: _TrustCard(
                        icon: Icons.ac_unit,
                        title: 'Professional HVAC Service',
                        description:
                            'Specialized cooling solutions tailored to regional climate demands with industry-grade tools and parts.',
                      ),
                    ),
                    SizedBox(width: 22),
                    Expanded(
                      child: _TrustCard(
                        icon: Icons.support_agent,
                        title: 'Responsive Support',
                        description:
                            'Prompt customer coordination, fast dispatch schedules and transparent communication at every stage.',
                      ),
                    ),
                    SizedBox(width: 22),
                    Expanded(
                      child: _TrustCard(
                        icon: Icons.engineering,
                        title: 'Experienced Technicians',
                        description:
                            'Trained technicians dedicated to high-standard installation, diagnostic troubleshooting and maintenance.',
                      ),
                    ),
                    SizedBox(width: 22),
                    Expanded(
                      child: _TrustCard(
                        icon: Icons.sentiment_very_satisfied,
                        title: 'Customer-Focused Service',
                        description:
                            'Clear job tracking, verified work completion and long-term cooling comfort for every client.',
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
                          child: _TrustCard(
                            icon: Icons.ac_unit,
                            title: 'Professional HVAC Service',
                            description:
                                'Specialized cooling solutions tailored to regional climate demands with industry-grade tools.',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _TrustCard(
                            icon: Icons.support_agent,
                            title: 'Responsive Support',
                            description:
                                'Prompt customer coordination, fast dispatch schedules and transparent communication.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(
                          child: _TrustCard(
                            icon: Icons.engineering,
                            title: 'Experienced Technicians',
                            description:
                                'Trained technicians dedicated to high-standard installation, diagnostic troubleshooting and maintenance.',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _TrustCard(
                            icon: Icons.sentiment_very_satisfied,
                            title: 'Customer-Focused Service',
                            description:
                                'Clear job tracking, verified work completion and long-term cooling comfort for every client.',
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: const [
                    _TrustCard(
                      icon: Icons.ac_unit,
                      title: 'Professional HVAC Service',
                      description:
                          'Specialized cooling solutions tailored to regional climate demands with industry-grade tools.',
                    ),
                    SizedBox(height: 16),
                    _TrustCard(
                      icon: Icons.support_agent,
                      title: 'Responsive Support',
                      description:
                          'Prompt customer coordination, fast dispatch schedules and transparent communication.',
                    ),
                    SizedBox(height: 16),
                    _TrustCard(
                      icon: Icons.engineering,
                      title: 'Experienced Technicians',
                      description:
                          'Trained technicians dedicated to high-standard installation, diagnostic troubleshooting and maintenance.',
                    ),
                    SizedBox(height: 16),
                    _TrustCard(
                      icon: Icons.sentiment_very_satisfied,
                      title: 'Customer-Focused Service',
                      description:
                          'Clear job tracking, verified work completion and long-term cooling comfort for every client.',
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

class _TrustCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _TrustCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_TrustCard> createState() => _TrustCardState();
}

class _TrustCardState extends State<_TrustCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GlassCard(
        isHoverable: true,
        padding: const EdgeInsets.all(26),
        borderColor: _isHovered
            ? LandingTheme.gold
            : Colors.white.withOpacity(0.12),
        backgroundColor: _isHovered
            ? Colors.white.withOpacity(0.12)
            : const Color(0xFF040E22).withOpacity(0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isHovered
                    ? LandingTheme.gold
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isHovered
                      ? LandingTheme.gold
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: _isHovered ? const Color(0xFF061A3D) : LandingTheme.gold,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
