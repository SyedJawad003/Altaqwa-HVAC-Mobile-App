import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';

/// 10. Contact Section with verified WhatsApp and placeholders for unconfirmed info.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

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
                  'GET IN TOUCH',
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
                'Contact Our Support Team',
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
                  'Reach out for inquiries regarding our cooling services, maintenance agreements, or the Al Taqwa mobile application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 56),

              // 4 Contact Cards
              if (isDesktop)
                Row(
                  children: [
                    const Expanded(
                      child: _ContactCard(
                        icon: Icons.phone_in_talk_outlined,
                        title: 'Phone Support',
                        info: 'To be confirmed',
                        subtext: 'Customer line coming soon',
                        isClickable: false,
                      ),
                    ),
                    const SizedBox(width: 22),
                    const Expanded(
                      child: _ContactCard(
                        icon: Icons.mail_outline,
                        title: 'Email Address',
                        info: 'To be confirmed',
                        subtext: 'Official email coming soon',
                        isClickable: false,
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.chat_bubble_outline,
                        title: 'Official WhatsApp',
                        info: '+971 50 610 9894',
                        subtext: 'Direct message support • 24/7',
                        isClickable: true,
                        isFeatured: true,
                        onTap: () => openWhatsApp(context),
                      ),
                    ),
                    const SizedBox(width: 22),
                    const Expanded(
                      child: _ContactCard(
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                        info: 'To be confirmed',
                        subtext: 'United Arab Emirates',
                        isClickable: false,
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
                          child: _ContactCard(
                            icon: Icons.phone_in_talk_outlined,
                            title: 'Phone Support',
                            info: 'To be confirmed',
                            subtext: 'Customer line coming soon',
                            isClickable: false,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.mail_outline,
                            title: 'Email Address',
                            info: 'To be confirmed',
                            subtext: 'Official email coming soon',
                            isClickable: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.chat_bubble_outline,
                            title: 'Official WhatsApp',
                            info: '+971 50 610 9894',
                            subtext: 'Direct message support',
                            isClickable: true,
                            isFeatured: true,
                            onTap: () => openWhatsApp(context),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          child: _ContactCard(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            info: 'To be confirmed',
                            subtext: 'United Arab Emirates',
                            isClickable: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _ContactCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'Official WhatsApp',
                      info: '+971 50 610 9894',
                      subtext: 'Direct message support • Tap to chat',
                      isClickable: true,
                      isFeatured: true,
                      onTap: () => openWhatsApp(context),
                    ),
                    const SizedBox(height: 16),
                    const _ContactCard(
                      icon: Icons.phone_in_talk_outlined,
                      title: 'Phone Support',
                      info: 'To be confirmed',
                      subtext: 'Customer line coming soon',
                      isClickable: false,
                    ),
                    const SizedBox(height: 16),
                    const _ContactCard(
                      icon: Icons.mail_outline,
                      title: 'Email Address',
                      info: 'To be confirmed',
                      subtext: 'Official email coming soon',
                      isClickable: false,
                    ),
                    const SizedBox(height: 16),
                    const _ContactCard(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      info: 'To be confirmed',
                      subtext: 'United Arab Emirates',
                      isClickable: false,
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

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String info;
  final String subtext;
  final bool isClickable;
  final bool isFeatured;
  final VoidCallback? onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.info,
    required this.subtext,
    required this.isClickable,
    this.isFeatured = false,
    this.onTap,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isClickable
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.isFeatured
                ? const Color(0xFF061A3D)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isFeatured
                  ? LandingTheme.gold
                  : (_isHovered
                      ? const Color(0xFF0B3A8C)
                      : const Color(0xFFE2E8F0)),
              width: widget.isFeatured ? 1.6 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (widget.isFeatured
                              ? LandingTheme.gold
                              : const Color(0xFF0B3A8C))
                          .withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : LandingTheme.softCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isFeatured
                      ? LandingTheme.gold
                      : LandingTheme.blueIce,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isFeatured
                      ? const Color(0xFF061A3D)
                      : const Color(0xFF0B3A8C),
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.isFeatured
                      ? Colors.white70
                      : const Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.info,
                style: TextStyle(
                  color: widget.isFeatured
                      ? LandingTheme.goldLight
                      : const Color(0xFF061A3D),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtext,
                style: TextStyle(
                  color: widget.isFeatured
                      ? Colors.white60
                      : const Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
              if (widget.isClickable) ...[
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Text(
                      'Open Chat',
                      style: TextStyle(
                        color: LandingTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward,
                        size: 14, color: LandingTheme.gold),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
