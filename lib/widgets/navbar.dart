import 'dart:ui';
import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';

/// Sticky responsive navigation bar with glassmorphic effect on scroll.
class StickyNavbar extends StatelessWidget {
  final bool isScrolled;
  final Function(String section) onNavigate;
  final VoidCallback onOpenMobileMenu;

  const StickyNavbar({
    super.key,
    required this.isScrolled,
    required this.onNavigate,
    required this.onOpenMobileMenu,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 980;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isScrolled ? 14 : 0,
          sigmaY: isScrolled ? 14 : 0,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: isScrolled ? 68 : 84,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 1200 ? 54 : (screenWidth > 600 ? 28 : 16),
          ),
          decoration: BoxDecoration(
            color: isScrolled
                ? const Color(0xFF040E22).withOpacity(0.88)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isScrolled
                    ? Colors.white.withOpacity(0.08)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            boxShadow: isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Logo & Wordmark
              GestureDetector(
                onTap: () => onNavigate('home'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Official Logo Image with error fallback
                      Image.asset(
                        'assets/logo2x.png',
                        height: isScrolled ? 36 : 44,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/altaqwa_logo.png',
                            height: isScrolled ? 36 : 44,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: isScrolled ? 36 : 42,
                                height: isScrolled ? 36 : 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LandingTheme.goldGradient,
                                ),
                                child: const Icon(
                                  Icons.ac_unit,
                                  color: Color(0xFF061A3D),
                                  size: 22,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'AL TAQWA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.8,
                            ),
                          ),
                          Text(
                            'Cooling System',
                            style: TextStyle(
                              color: LandingTheme.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Middle: Desktop Navigation Links
              if (isDesktop)
                Row(
                  children: [
                    _NavLink(title: 'Home', onTap: () => onNavigate('home')),
                    _NavLink(title: 'About', onTap: () => onNavigate('why')),
                    _NavLink(title: 'Services', onTap: () => onNavigate('services')),
                    _NavLink(
                        title: 'How It Works',
                        onTap: () => onNavigate('how-it-works')),
                    _NavLink(title: 'App', onTap: () => onNavigate('app')),
                    _NavLink(title: 'Contact', onTap: () => onNavigate('contact')),
                  ],
                ),

              // Right: Action Button or Hamburger
              if (isDesktop)
                _DownloadNavButton(
                  onTap: () => openCustomerPanel(context),
                )
              else
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: onOpenMobileMenu,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _NavLink({required this.title, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: _isHovered ? LandingTheme.goldLight : Colors.white70,
                  fontSize: 14,
                  fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2,
                width: _isHovered ? 20 : 0,
                decoration: BoxDecoration(
                  color: LandingTheme.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadNavButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DownloadNavButton({required this.onTap});

  @override
  State<_DownloadNavButton> createState() => _DownloadNavButtonState();
}

class _DownloadNavButtonState extends State<_DownloadNavButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LandingTheme.goldGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: LandingTheme.gold.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: LandingTheme.gold.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.download_rounded, color: Color(0xFF061A3D), size: 17),
              SizedBox(width: 8),
              Text(
                'Download App',
                style: TextStyle(
                  color: Color(0xFF061A3D),
                  fontSize: 13.5,
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

/// Mobile Navigation Drawer
class MobileNavDrawer extends StatelessWidget {
  final Function(String section) onNavigate;

  const MobileNavDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      color: const Color(0xFF061A3D),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'AL TAQWA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                    ),
                  ),
                  Text(
                    'Cooling System',
                    style: TextStyle(
                      color: LandingTheme.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          _buildMobileLink(context, 'Home', 'home'),
          _buildMobileLink(context, 'About', 'why'),
          _buildMobileLink(context, 'Services', 'services'),
          _buildMobileLink(context, 'How It Works', 'how-it-works'),
          _buildMobileLink(context, 'Mobile App', 'app'),
          _buildMobileLink(context, 'Contact', 'contact'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                openCustomerPanel(context);
              },
              icon: const Icon(Icons.download, color: Color(0xFF061A3D), size: 18),
              label: const Text(
                'Download App',
                style: TextStyle(
                  color: Color(0xFF061A3D),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: LandingTheme.gold,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '© 2026 AL TAQWA Cooling System',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLink(BuildContext context, String title, String section) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 13, color: LandingTheme.gold),
      onTap: () {
        Navigator.of(context).pop();
        onNavigate(section);
      },
    );
  }
}
