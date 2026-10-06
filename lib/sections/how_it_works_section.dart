import 'package:flutter/material.dart';
import '../theme/landing_theme.dart';

/// 5. How It Works (Clean 4-step responsive timeline: Horizontal on desktop, Vertical on mobile).
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

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
              // Badge
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
                  'SIMPLE 4-STEP PROCESS',
                  style: TextStyle(
                    color: Color(0xFF0B3A8C),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Headline
              const Text(
                'How It Works',
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
                constraints: const BoxConstraints(maxWidth: 620),
                child: const Text(
                  'A streamlined HVAC service lifecycle designed to give you peace of mind from initial booking to certified completion.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 64),

              // Timeline: Horizontal on Desktop, Vertical on Mobile
              if (isDesktop)
                _buildHorizontalTimeline()
              else
                _buildVerticalTimeline(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalTimeline() {
    return Column(
      children: [
        // Steps Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: _StepCard(
                number: '01',
                title: 'Request',
                description:
                    'Submit your HVAC service request through the app in just a few taps.',
                icon: Icons.app_registration,
              ),
            ),
            _TimelineConnector(),
            Expanded(
              child: _StepCard(
                number: '02',
                title: 'Assignment',
                description:
                    'Our team reviews your request and assigns a certified technician.',
                icon: Icons.person_search_outlined,
              ),
            ),
            _TimelineConnector(),
            Expanded(
              child: _StepCard(
                number: '03',
                title: 'Service',
                description:
                    'Your assigned technician handles the requested cooling service on site.',
                icon: Icons.handyman_outlined,
              ),
            ),
            _TimelineConnector(),
            Expanded(
              child: _StepCard(
                number: '04',
                title: 'Complete',
                description:
                    'Track your service status until completion with full digital records.',
                icon: Icons.task_alt_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalTimeline() {
    return Column(
      children: const [
        _VerticalStepItem(
          number: '01',
          title: 'Request',
          description:
              'Submit your HVAC service request through the app in just a few taps.',
          icon: Icons.app_registration,
          isLast: false,
        ),
        _VerticalStepItem(
          number: '02',
          title: 'Assignment',
          description:
              'Our team reviews your request and assigns a certified technician.',
          icon: Icons.person_search_outlined,
          isLast: false,
        ),
        _VerticalStepItem(
          number: '03',
          title: 'Service',
          description:
              'Your assigned technician handles the requested cooling service on site.',
          icon: Icons.handyman_outlined,
          isLast: false,
        ),
        _VerticalStepItem(
          number: '04',
          title: 'Complete',
          description:
              'Track your service status until completion with full digital records.',
          icon: Icons.task_alt_outlined,
          isLast: true,
        ),
      ],
    );
  }
}

class _StepCard extends StatefulWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered ? LandingTheme.gold : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: LandingTheme.gold.withOpacity(0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : LandingTheme.softCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Step Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF061A3D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LandingTheme.gold, width: 1.2),
                  ),
                  child: Text(
                    widget.number,
                    style: const TextStyle(
                      color: LandingTheme.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(
                  widget.icon,
                  color: _isHovered
                      ? const Color(0xFF0B3A8C)
                      : const Color(0xFF94A3B8),
                  size: 26,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFF061A3D),
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.description,
              style: const TextStyle(
                color: Color(0xFF64748B),
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

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 8, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFCBD5E1),
            ),
          ),
          Container(
            width: 24,
            height: 2,
            color: const Color(0xFFE2E8F0),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: LandingTheme.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalStepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final bool isLast;

  const _VerticalStepItem({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Line Column
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF061A3D),
                  shape: BoxShape.circle,
                  border: Border.all(color: LandingTheme.gold, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: LandingTheme.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: LandingTheme.softCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF061A3D),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Icon(icon, color: const Color(0xFF0B3A8C), size: 20),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.4,
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
}
