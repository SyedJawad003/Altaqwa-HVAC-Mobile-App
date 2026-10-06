import 'package:flutter/material.dart';
import 'theme/landing_theme.dart';
import 'widgets/navbar.dart';
import 'widgets/floating_whatsapp.dart';
import 'sections/hero_section.dart';
import 'sections/why_app_section.dart';
import 'sections/services_section.dart';
import 'sections/app_showcase_section.dart';
import 'sections/how_it_works_section.dart';
import 'sections/technician_section.dart';
import 'sections/customer_experience_section.dart';
import 'sections/trust_section.dart';
import 'sections/download_section.dart';
import 'sections/contact_section.dart';
import 'sections/footer_section.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlTaqwaLandingApp());
}

class AlTaqwaLandingApp extends StatelessWidget {
  const AlTaqwaLandingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AL TAQWA Cooling System | HVAC Services & Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: LandingTheme.navyDark,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0B3A8C),
          secondary: Color(0xFFC9A24A),
          surface: Color(0xFF040E22),
          // Strict rule: NO RED ANYWHERE
          error: Color(0xFF0B3A8C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const LandingPage(),
    );
  }
}

/// Single-page coordinator for the AL TAQWA Cooling System Landing Website.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _whyKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _appKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if (offset > 40 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (offset <= 40 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    GlobalKey? targetKey;
    switch (section) {
      case 'home':
        targetKey = _heroKey;
        break;
      case 'why':
        targetKey = _whyKey;
        break;
      case 'services':
        targetKey = _servicesKey;
        break;
      case 'how-it-works':
        targetKey = _howItWorksKey;
        break;
      case 'app':
        targetKey = _appKey;
        break;
      case 'contact':
        targetKey = _contactKey;
        break;
    }

    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: LandingTheme.navyDark,
      endDrawer: Drawer(
        child: MobileNavDrawer(
          onNavigate: _scrollToSection,
        ),
      ),
      body: Stack(
        children: [
          // Scrollable Page Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // 1. Hero Section
                Container(
                  key: _heroKey,
                  child: HeroSection(
                    onExploreServices: () => _scrollToSection('services'),
                  ),
                ),

                // 2. Why Use The App Section
                Container(
                  key: _whyKey,
                  child: const WhyAppSection(),
                ),

                // 3. HVAC Services Section
                Container(
                  key: _servicesKey,
                  child: const ServicesSection(),
                ),

                // 4. Mobile App Showcase Section
                Container(
                  key: _appKey,
                  child: const AppShowcaseSection(),
                ),

                // 5. How It Works Section
                Container(
                  key: _howItWorksKey,
                  child: const HowItWorksSection(),
                ),

                // 6. Technician & Service Workflow Section
                const TechnicianSection(),

                // 7. Customer Experience Section
                const CustomerExperienceSection(),

                // 8. Why Al Taqwa / Trust Section
                const TrustSection(),

                // 9. Download App CTA Section
                const DownloadSection(),

                // 10. Contact Section
                Container(
                  key: _contactKey,
                  child: const ContactSection(),
                ),

                // 11. Footer Section
                FooterSection(
                  onNavigate: _scrollToSection,
                ),
              ],
            ),
          ),

          // Sticky Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: StickyNavbar(
              isScrolled: _isScrolled,
              onNavigate: _scrollToSection,
              onOpenMobileMenu: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),

          // 12. Floating WhatsApp Action Button
          const FloatingWhatsAppButton(),
        ],
      ),
    );
  }
}
