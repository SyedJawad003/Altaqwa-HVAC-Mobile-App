import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin/admin_theme.dart';
import 'customer/theme/app_theme.dart';
import 'firebase_options.dart';
import 'landing_page.dart';
import 'main_admin.dart';
import 'main_customer.dart';
import 'main_supervisor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initializationError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
  } catch (error) {
    initializationError = error;
  }

  // 1. On Mobile platforms (Android/iOS), default directly to Customer App
  if (!kIsWeb) {
    runApp(CustomerApp(initializationError: initializationError));
    return;
  }

  // 2. On Web, inspect URL query parameters or hash route fragments
  // e.g.:
  // http://localhost:port/?role=admin or /#/admin -> Admin Dashboard
  // http://localhost:port/?role=customer or /#/customer -> Customer App
  // http://localhost:port/?role=supervisor or /#/supervisor -> Supervisor App
  // http://localhost:port/?role=landing or /#/landing -> Marketing Landing Page
  final uri = Uri.base;
  final roleParam = (uri.queryParameters['role'] ?? '').toLowerCase().trim();
  final path = uri.path.toLowerCase();
  final fragment = uri.fragment.toLowerCase();

  final isAdmin = roleParam == 'admin' ||
      path.contains('/admin') ||
      fragment.contains('admin');
  final isCustomer = roleParam == 'customer' ||
      path.contains('/customer') ||
      fragment.contains('customer');
  final isSupervisor = roleParam == 'supervisor' ||
      path.contains('/supervisor') ||
      fragment.contains('supervisor');
  final isLanding = roleParam == 'landing' ||
      path.contains('/landing') ||
      fragment.contains('landing');

  if (isAdmin) {
    runApp(AdminApp(initializationError: initializationError));
    return;
  }
  if (isCustomer) {
    runApp(CustomerApp(initializationError: initializationError));
    return;
  }
  if (isSupervisor) {
    runApp(SupervisorApp(initializationError: initializationError));
    return;
  }
  if (isLanding) {
    runApp(const AlTaqwaLandingApp());
    return;
  }

  // 3. If running on Web without a specific role parameter, launch the Unified Portal
  runApp(UnifiedPortalApp(initializationError: initializationError));
}

/// Unified Portal: allows switching immediately between Admin, Customer, Supervisor, and Landing Page.
class UnifiedPortalApp extends StatefulWidget {
  final Object? initializationError;

  const UnifiedPortalApp({super.key, this.initializationError});

  @override
  State<UnifiedPortalApp> createState() => _UnifiedPortalAppState();
}

class _UnifiedPortalAppState extends State<UnifiedPortalApp> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    if (_selectedRole == 'admin') {
      return AdminApp(initializationError: widget.initializationError);
    }
    if (_selectedRole == 'customer') {
      return CustomerApp(initializationError: widget.initializationError);
    }
    if (_selectedRole == 'supervisor') {
      return SupervisorApp(initializationError: widget.initializationError);
    }
    if (_selectedRole == 'landing') {
      return const AlTaqwaLandingApp();
    }

    return MaterialApp(
      title: 'Al Taqwa Cooling System - App Portal',
      debugShowCheckedModeBanner: false,
      theme: adminWebTheme,
      home: Scaffold(
        backgroundColor: const Color(0xFF07142A),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Badge
                    Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/altaqwa_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.ac_unit_rounded,
                          color: goldLight,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Header
                    const Text(
                      'AL TAQWA COOLING SYSTEM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select an application portal to launch',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Role Cards Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 600;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(
                              width: isWide ? (constraints.maxWidth - 16) / 2 : double.infinity,
                              child: _buildPortalCard(
                                title: 'Admin Web Dashboard',
                                subtitle: 'Manage customers, bookings, technicians & dispatch',
                                icon: Icons.admin_panel_settings_rounded,
                                badge: 'Recommended on Web',
                                primaryColor: navy,
                                accentColor: gold,
                                onTap: () => setState(() => _selectedRole = 'admin'),
                              ),
                            ),
                            SizedBox(
                              width: isWide ? (constraints.maxWidth - 16) / 2 : double.infinity,
                              child: _buildPortalCard(
                                title: 'Customer Application',
                                subtitle: 'Book maintenance, get quotes & live 1-on-1 chat',
                                icon: Icons.person_pin_circle_rounded,
                                badge: 'Customer Portal',
                                primaryColor: const Color(0xFF0F3970),
                                accentColor: const Color(0xFF38BDF8),
                                onTap: () => setState(() => _selectedRole = 'customer'),
                              ),
                            ),
                            SizedBox(
                              width: isWide ? (constraints.maxWidth - 16) / 2 : double.infinity,
                              child: _buildPortalCard(
                                title: 'Supervisor Portal',
                                subtitle: 'Supervise site operations, verify jobs & issues',
                                icon: Icons.engineering_rounded,
                                badge: 'Operations',
                                primaryColor: const Color(0xFF1E293B),
                                accentColor: const Color(0xFFF59E0B),
                                onTap: () => setState(() => _selectedRole = 'supervisor'),
                              ),
                            ),
                            SizedBox(
                              width: isWide ? (constraints.maxWidth - 16) / 2 : double.infinity,
                              child: _buildPortalCard(
                                title: 'Landing Website',
                                subtitle: 'Official UAE marketing site with app walkthroughs',
                                icon: Icons.public_rounded,
                                badge: 'Marketing Page',
                                primaryColor: const Color(0xFF132A4A),
                                accentColor: goldLight,
                                onTap: () => setState(() => _selectedRole = 'landing'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Quick CLI Helper Notice
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Quick terminal commands for direct launch:',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Admin:   flutter run -t lib/main_admin.dart -d chrome\n'
                            'Customer: flutter run -t lib/main_customer.dart -d chrome\n'
                            'Landing: flutter run -t lib/landing_page.dart -d chrome',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: goldLight,
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color primaryColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E36),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withValues(alpha: 0.6)),
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Launch Portal',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: accentColor, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}