import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';
import '../widgets/phone_mockup.dart';

/// 9. Download App CTA Section (Deep blue -> royal blue gradient with gold highlights and phone mockups).
class DownloadSection extends StatelessWidget {
  const DownloadSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF030D1E),
            Color(0xFF061A3D),
            Color(0xFF0B3A8C),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 1200 ? 64 : (screenWidth > 600 ? 32 : 18),
        vertical: isDesktop ? 96 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 56 : (screenWidth > 500 ? 32 : 20),
              vertical: isDesktop ? 64 : 48,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B2B63),
                  Color(0xFF061A3D),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: LandingTheme.gold.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: LandingTheme.gold.withOpacity(0.12),
                  blurRadius: 30,
                ),
              ],
            ),
            child: isDesktop
                ? Row(
                    children: [
                      // Left: Copy & Store Buttons
                      Expanded(
                        flex: 13,
                        child: _buildCtaContent(context),
                      ),
                      const SizedBox(width: 48),
                      // Right: 2 Phone Mockups
                      Expanded(
                        flex: 11,
                        child: _buildCtaPhones(),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCtaContent(context, centerText: true),
                      const SizedBox(height: 48),
                      _buildCtaPhones(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCtaContent(BuildContext context, {bool centerText = false}) {
    return Column(
      crossAxisAlignment:
          centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
            'AVAILABLE NOW',
            style: TextStyle(
              color: LandingTheme.goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Headline
        Text(
          'Your Cooling Service Is Just a Tap Away.',
          textAlign: centerText ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          'Download the Al Taqwa app and make HVAC service management easier. Book certified maintenance, follow technician dispatch and view full service records on your mobile.',
          textAlign: centerText ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // App Store & Google Play Buttons
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: centerText ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _StoreButton(
              isApple: true,
              onTap: () => openAppStore(context),
            ),
            _StoreButton(
              isApple: false,
              onTap: () => openPlayStore(context),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Customer Panel direct fallback note
        Text(
          'Instant web access: Opens official Al Taqwa Customer Panel',
          style: TextStyle(
            color: LandingTheme.goldLight.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCtaPhones() {
    return Center(
      child: SizedBox(
        height: 380,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: const [
            Positioned(
              left: 0,
              top: 20,
              child: Opacity(
                opacity: 0.9,
                child: PhoneMockup(
                  screenType: PhoneScreenType.login,
                  scale: 0.65,
                  showFloatingShadow: false,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              child: PhoneMockup(
                screenType: PhoneScreenType.dashboard,
                scale: 0.72,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreButton extends StatefulWidget {
  final bool isApple;
  final VoidCallback onTap;

  const _StoreButton({required this.isApple, required this.onTap});

  @override
  State<_StoreButton> createState() => _StoreButtonState();
}

class _StoreButtonState extends State<_StoreButton> {
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withOpacity(0.18)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? LandingTheme.gold
                  : Colors.white.withOpacity(0.25),
              width: 1.3,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: LandingTheme.gold.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isApple ? Icons.apple : Icons.shop_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isApple
                            ? 'Download on the'
                            : 'GET IT ON',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 9.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        widget.isApple ? 'App Store' : 'Google Play',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: LandingTheme.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Customer Panel Access',
                  style: TextStyle(
                    color: LandingTheme.goldLight,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
