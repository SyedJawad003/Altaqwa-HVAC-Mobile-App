import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';

/// 11. Dark Navy Premium Footer with Quick Links, Services, App links and legal notes.
class FooterSection extends StatelessWidget {
  final Function(String section) onNavigate;

  const FooterSection({super.key, required this.onNavigate});

  void _showPolicyDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF061A3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E3A8A)),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Text(
                body,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: LandingTheme.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    return Container(
      color: LandingTheme.navyDark,
      padding: EdgeInsets.fromLTRB(
        screenWidth > 1200 ? 64 : (screenWidth > 600 ? 32 : 18),
        72,
        screenWidth > 1200 ? 64 : (screenWidth > 600 ? 32 : 18),
        36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              // Top Columns
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1: Brand Info
                    Expanded(
                      flex: 4,
                      child: _buildBrandCol(context),
                    ),
                    const SizedBox(width: 48),
                    // Col 2: Quick Links
                    Expanded(
                      flex: 2,
                      child: _buildLinksCol('Quick Links', [
                        _FooterLink('Home', () => onNavigate('home')),
                        _FooterLink('About App', () => onNavigate('why')),
                        _FooterLink('Services', () => onNavigate('services')),
                        _FooterLink(
                            'How It Works', () => onNavigate('how-it-works')),
                        _FooterLink('Mobile App', () => onNavigate('app')),
                        _FooterLink('Contact Us', () => onNavigate('contact')),
                      ]),
                    ),
                    const SizedBox(width: 32),
                    // Col 3: Services
                    Expanded(
                      flex: 3,
                      child: _buildLinksCol('HVAC Services', [
                        _FooterLink('AC Installation', () => onNavigate('services')),
                        _FooterLink('AC Repair & Diagnostics', () => onNavigate('services')),
                        _FooterLink('AC Preventive Maintenance', () => onNavigate('services')),
                        _FooterLink('HVAC Airflow Balancing', () => onNavigate('services')),
                        _FooterLink('Cooling System Inspection', () => onNavigate('services')),
                      ]),
                    ),
                    const SizedBox(width: 32),
                    // Col 4: Mobile App & Contact
                    Expanded(
                      flex: 3,
                      child: _buildAppContactCol(context),
                    ),
                  ],
                )
              else if (isTablet)
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildBrandCol(context)),
                        const SizedBox(width: 32),
                        Expanded(child: _buildAppContactCol(context)),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildLinksCol('Quick Links', [
                            _FooterLink('Home', () => onNavigate('home')),
                            _FooterLink('About', () => onNavigate('why')),
                            _FooterLink('Services', () => onNavigate('services')),
                            _FooterLink('How It Works',
                                () => onNavigate('how-it-works')),
                            _FooterLink('Mobile App', () => onNavigate('app')),
                            _FooterLink('Contact', () => onNavigate('contact')),
                          ]),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: _buildLinksCol('HVAC Services', [
                            _FooterLink('AC Installation', () => onNavigate('services')),
                            _FooterLink('AC Repair', () => onNavigate('services')),
                            _FooterLink('AC Maintenance', () => onNavigate('services')),
                            _FooterLink('HVAC Services', () => onNavigate('services')),
                            _FooterLink('System Inspection', () => onNavigate('services')),
                          ]),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandCol(context),
                    const SizedBox(height: 36),
                    _buildLinksCol('Quick Links', [
                      _FooterLink('Home', () => onNavigate('home')),
                      _FooterLink('About', () => onNavigate('why')),
                      _FooterLink('Services', () => onNavigate('services')),
                      _FooterLink(
                          'How It Works', () => onNavigate('how-it-works')),
                      _FooterLink('Mobile App', () => onNavigate('app')),
                      _FooterLink('Contact', () => onNavigate('contact')),
                    ]),
                    const SizedBox(height: 36),
                    _buildLinksCol('HVAC Services', [
                      _FooterLink('AC Installation', () => onNavigate('services')),
                      _FooterLink('AC Repair', () => onNavigate('services')),
                      _FooterLink('AC Maintenance', () => onNavigate('services')),
                      _FooterLink('HVAC Services', () => onNavigate('services')),
                    ]),
                    const SizedBox(height: 36),
                    _buildAppContactCol(context),
                  ],
                ),

              const SizedBox(height: 56),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 32),

              // Bottom Bar: Copyright & Policies
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '© 2026 AL TAQWA Cooling System. All Rights Reserved.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 16,
                    children: [
                      GestureDetector(
                        onTap: () => _showPolicyDialog(
                          context,
                          'Privacy Policy',
                          'AL TAQWA Cooling System respects your privacy and ensures that your personal information, service addresses, and contact numbers are handled securely and in full accordance with UAE data protection standards. Your details are used solely to schedule, manage, and complete your requested HVAC maintenance and cooling services.',
                        ),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showPolicyDialog(
                          context,
                          'Terms & Conditions',
                          'By using the AL TAQWA Cooling System mobile application and web portal, you agree to our standard service terms. All HVAC repairs, installations, and maintenance are conducted by certified technicians following manufacturer specifications and local UAE engineering guidelines.',
                        ),
                        child: Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo2x.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/altaqwa_logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: LandingTheme.gold,
                      ),
                      child: const Icon(Icons.ac_unit,
                          color: Color(0xFF061A3D), size: 22),
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AL TAQWA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                Text(
                  'Cooling System',
                  style: TextStyle(
                    color: LandingTheme.gold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'AL TAQWA Cooling System provides modern HVAC and cooling services across the UAE, powered by a mobile-first digital experience.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13.5,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        // Social Media Icons
        Row(
          children: [
            _buildSocialIcon(Icons.chat, () => openWhatsApp(context)),
            const SizedBox(width: 10),
            _buildSocialIcon(Icons.public, () => openCustomerPanel(context)),
            const SizedBox(width: 10),
            _buildSocialIcon(Icons.alternate_email, () => openCustomerPanel(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white70, size: 16),
      ),
    );
  }

  Widget _buildLinksCol(String title, List<_FooterLink> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 18),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: links.map((l) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: l.onTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    l.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAppContactCol(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Application',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Manage HVAC requests, technician tracking and invoices online.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.68),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () => openCustomerPanel(context),
          icon: const Icon(Icons.download, color: Color(0xFF061A3D), size: 16),
          label: const Text(
            'Download App',
            style: TextStyle(
              color: Color(0xFF061A3D),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: LandingTheme.gold,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => openWhatsApp(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chat_bubble_outline,
                  color: LandingTheme.gold, size: 16),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'WhatsApp: +971 50 610 9894',
                  style: TextStyle(
                    color: LandingTheme.goldLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterLink {
  final String label;
  final VoidCallback onTap;
  _FooterLink(this.label, this.onTap);
}
