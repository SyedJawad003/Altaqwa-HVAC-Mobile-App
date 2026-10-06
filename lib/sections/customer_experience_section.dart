import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';
import '../widgets/phone_mockup.dart';

/// 7. Customer Experience Section (White section with large smartphone + staggered notification cards).
class CustomerExperienceSection extends StatelessWidget {
  const CustomerExperienceSection({super.key});

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
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Large Smartphone
                    Expanded(
                      flex: 11,
                      child: Center(
                        child: PhoneMockup(
                          screenType: PhoneScreenType.tracking,
                          scale: 0.95,
                        ),
                      ),
                    ),
                    const SizedBox(width: 56),
                    // Right: Headline + Staggered Notifications
                    Expanded(
                      flex: 13,
                      child: _buildNotificationsColumn(context),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNotificationsColumn(context, centerText: true),
                    const SizedBox(height: 48),
                    PhoneMockup(
                      screenType: PhoneScreenType.tracking,
                      scale: screenWidth < 500 ? 0.80 : 0.88,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNotificationsColumn(BuildContext context,
      {bool centerText = false}) {
    return Column(
      crossAxisAlignment:
          centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
            'TRANSPARENT JOURNEY',
            style: TextStyle(
              color: Color(0xFF0B3A8C),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Headline
        Text(
          'Stay Connected From Request to Completion.',
          textAlign: centerText ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF061A3D),
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),

        // Description
        Text(
          'No guessing, no endless follow-up phone calls. The Al Taqwa mobile app keeps you informed at each step with proactive notifications.',
          textAlign: centerText ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // 4 Staggered Notification Cards
        _NotificationCard(
          icon: Icons.mark_email_read_outlined,
          title: 'Your service request has been received.',
          description:
              'Job #AT-8842 scheduled for inspection with preferred time confirmed.',
          time: 'Just now',
          accentColor: const Color(0xFF0B3A8C),
        ),
        const SizedBox(height: 14),
        _NotificationCard(
          icon: Icons.person_pin_outlined,
          title: 'Technician assigned to your request.',
          description:
              'Tariq Mansoor (Senior HVAC Specialist) assigned to your service call.',
          time: '10 min ago',
          accentColor: LandingTheme.goldDark,
        ),
        const SizedBox(height: 14),
        _NotificationCard(
          icon: Icons.near_me_outlined,
          title: 'Your technician is on the way.',
          description:
              'Service vehicle dispatched. Estimated arrival in 15 minutes.',
          time: '25 min ago',
          accentColor: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 14),
        _NotificationCard(
          icon: Icons.check_circle_outline,
          title: 'Service completed successfully.',
          description:
              'Cooling parameters checked, filters cleaned and job signed off.',
          time: '1 hour ago',
          accentColor: LandingTheme.statusSuccess,
        ),
        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: () => openCustomerPanel(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF061A3D),
            foregroundColor: LandingTheme.gold,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: LandingTheme.gold, width: 1.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.open_in_new, color: LandingTheme.gold, size: 16),
              SizedBox(width: 8),
              Text(
                'Open Al Taqwa Portal',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: LandingTheme.gold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final Color accentColor;

  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    required this.accentColor,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.accentColor
                : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : LandingTheme.softCardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: widget.accentColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFF061A3D),
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      Text(
                        widget.time,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
