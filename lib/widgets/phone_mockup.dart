import 'package:flutter/material.dart';
import '../theme/landing_theme.dart';

enum PhoneScreenType {
  login,
  dashboard,
  booking,
  tracking,
  notifications,
}

/// Realistic smartphone frame built purely with Flutter widgets.
/// Features titanium bezel, dynamic island, status bar, and realistic Al Taqwa UI.
class PhoneMockup extends StatelessWidget {
  final PhoneScreenType screenType;
  final double scale;
  final bool showFloatingShadow;

  const PhoneMockup({
    super.key,
    required this.screenType,
    this.scale = 1.0,
    this.showFloatingShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    const phoneWidth = 280.0;
    const phoneHeight = 570.0;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: phoneWidth,
        height: phoneHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),
          color: const Color(0xFF0B1324),
          border: Border.all(
            color: const Color(0xFF334155),
            width: 3.5,
          ),
          boxShadow: showFloatingShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.55),
                    blurRadius: 36,
                    spreadRadius: -4,
                    offset: const Offset(0, 22),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0B3A8C).withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: Container(
            color: const Color(0xFF061A3D),
            child: Stack(
              children: [
                // Screen content based on screen type
                Positioned.fill(
                  child: _buildScreenContent(screenType),
                ),

                // Top Status Bar & Dynamic Island
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildStatusBar(),
                ),

                // Bottom Home Bar Indicator
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 96,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 18, right: 18, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '09:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          // Dynamic Island Notch
          Container(
            width: 72,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Row(
            children: const [
              Icon(Icons.signal_cellular_alt, color: Colors.white, size: 12),
              SizedBox(width: 3),
              Icon(Icons.wifi, color: Colors.white, size: 12),
              SizedBox(width: 3),
              Icon(Icons.battery_full, color: Colors.white, size: 13),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScreenContent(PhoneScreenType type) {
    switch (type) {
      case PhoneScreenType.login:
        return const _LoginScreenView();
      case PhoneScreenType.dashboard:
        return const _DashboardScreenView();
      case PhoneScreenType.booking:
        return const _BookingScreenView();
      case PhoneScreenType.tracking:
        return const _TrackingScreenView();
      case PhoneScreenType.notifications:
        return const _NotificationsScreenView();
    }
  }
}

// -------------------------------------------------------------
// 1. SCREEN: LOGIN / REGISTER
// -------------------------------------------------------------
class _LoginScreenView extends StatelessWidget {
  const _LoginScreenView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF040E22),
            Color(0xFF061A3D),
            Color(0xFF0B2B63),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 42, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Logo & Snowflake
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LandingTheme.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: LandingTheme.gold.withOpacity(0.4),
                    blurRadius: 16,
                  )
                ],
              ),
              child: const Icon(
                Icons.ac_unit,
                color: Color(0xFF061A3D),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'AL TAQWA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const Text(
            'Cooling System',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LandingTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Welcome Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage AC services & maintenance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Mobile field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF040E22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E3A8A)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '+971 ',
                        style: TextStyle(
                          color: LandingTheme.gold,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '50 123 4567',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Password placeholder
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF040E22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E3A8A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '••••••••••••',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const Icon(Icons.visibility_off_outlined,
                          color: Colors.white38, size: 13),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Sign in button
                Container(
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LandingTheme.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: LandingTheme.gold.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Sign In to Al Taqwa',
                      style: TextStyle(
                        color: Color(0xFF061A3D),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              'New customer? Register instantly in UAE',
              style: TextStyle(
                color: LandingTheme.gold.withOpacity(0.85),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. SCREEN: CUSTOMER HOME DASHBOARD
// -------------------------------------------------------------
class _DashboardScreenView extends StatelessWidget {
  const _DashboardScreenView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(14, 38, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF061A3D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: LandingTheme.gold, width: 1.2),
                      ),
                      child: const Center(
                        child: Text(
                          'AT',
                          style: TextStyle(
                            color: LandingTheme.gold,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Good Morning,',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 8.5),
                          ),
                          Text(
                            'Ahmed Al Mazrouei',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.notifications_none,
                    color: Color(0xFF0B3A8C), size: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // AC Status Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LandingTheme.cardBlueGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B3A8C).withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.ac_unit, color: LandingTheme.gold, size: 14),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Villa Central AC #01',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: LandingTheme.statusSuccess.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: LandingTheme.statusSuccess.withOpacity(0.5)),
                      ),
                      child: const Text(
                        'Optimal',
                        style: TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      '21°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cooling Mode • Auto Fan',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white70, fontSize: 8),
                          ),
                          Text(
                            'Airflow: 100% Efficiency',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: LandingTheme.goldLight,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Services
          const Text(
            'Quick Cooling Services',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuickAction('Book AC\nService', Icons.build_outlined, true),
              const SizedBox(width: 8),
              _buildQuickAction('Emergency\nCooling', Icons.flash_on, false),
              const SizedBox(width: 8),
              _buildQuickAction('Maintenance\nPlan', Icons.calendar_today, false),
            ],
          ),
          const SizedBox(height: 12),

          // Active Job Alert
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF061A3D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.engineering_outlined,
                      color: LandingTheme.gold, size: 14),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AC Inspection Today',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                        ),
                      ),
                      Text(
                        'Technician dispatched • 2:30 PM',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 8),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Color(0xFF94A3B8), size: 10),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Navigation Mockup
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _BottomNavIcon(Icons.home_filled, 'Home', true),
                _BottomNavIcon(Icons.build_outlined, 'Services', false),
                _BottomNavIcon(Icons.assignment_outlined, 'Requests', false),
                _BottomNavIcon(Icons.person_outline, 'Profile', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, bool active) {
    return Expanded(
      child: Container(
        height: 68,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF061A3D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? LandingTheme.gold : const Color(0xFFE2E8F0),
            width: active ? 1.2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: active ? LandingTheme.gold : const Color(0xFF0B3A8C),
              size: 15,
            ),
            Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF0F172A),
                fontSize: 8,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomNavIcon(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: active ? const Color(0xFF0B3A8C) : const Color(0xFF94A3B8),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 7.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? const Color(0xFF0B3A8C) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 3. SCREEN: SERVICE BOOKING
// -------------------------------------------------------------
class _BookingScreenView extends StatelessWidget {
  const _BookingScreenView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(14, 38, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.arrow_back_ios, size: 12, color: Color(0xFF061A3D)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Book Cooling Service',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF061A3D),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Service Type
          const Text(
            'Select HVAC Service',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildTypePill('AC Repair', true),
              const SizedBox(width: 6),
              _buildTypePill('Maintenance', false),
              const SizedBox(width: 6),
              _buildTypePill('Installation', false),
            ],
          ),
          const SizedBox(height: 12),

          // AC Unit selection
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AC System Type',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 8),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Ducted Split / Central Unit',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 9.5,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF0B3A8C), size: 14),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Preferred Schedule
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.access_time_filled,
                      color: Color(0xFF0B3A8C), size: 13),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Preferred Date & Time',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 8),
                    ),
                    Text(
                      'Tomorrow • 02:00 PM - 04:00 PM',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Notes
          Container(
            padding: const EdgeInsets.all(10),
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Cooling airflow reduced in master bedroom. Needs gas pressure check.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 8),
            ),
          ),

          const Spacer(),

          // Submit Request Button
          Container(
            height: 38,
            decoration: BoxDecoration(
              gradient: LandingTheme.goldGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: LandingTheme.gold.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Submit Service Request',
                style: TextStyle(
                  color: Color(0xFF061A3D),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypePill(String title, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF061A3D) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? LandingTheme.gold : const Color(0xFFE2E8F0),
            width: active ? 1.2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 4. SCREEN: TRACK SERVICE (ASSIGNED TECHNICIAN & PROGRESS)
// -------------------------------------------------------------
class _TrackingScreenView extends StatelessWidget {
  const _TrackingScreenView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(14, 38, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Job #AT-8842',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF061A3D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF061A3D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LandingTheme.gold),
                ),
                child: const Text(
                  'In Progress',
                  style: TextStyle(
                    color: LandingTheme.gold,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Assigned Technician Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF061A3D),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person,
                            color: LandingTheme.gold, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tariq Mansoor',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                          Text(
                            'Certified HVAC Specialist',
                            style: TextStyle(
                                color: Color(0xFF64748B), fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF3E3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.star,
                              color: LandingTheme.goldDark, size: 10),
                          SizedBox(width: 2),
                          Text(
                            '4.9',
                            style: TextStyle(
                              color: LandingTheme.goldDark,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Al Taqwa Fleet #14',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.phone_in_talk,
                            color: Color(0xFF0B3A8C), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Call Technician',
                          style: TextStyle(
                            color: Color(0xFF0B3A8C),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4-Step Progress Timeline
          const Text(
            'Live Service Milestones',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          _buildStep(
            number: '01',
            title: 'Request Received',
            subtitle: 'Confirmed by Al Taqwa Support',
            completed: true,
          ),
          _buildStep(
            number: '02',
            title: 'Technician Assigned',
            subtitle: 'Tariq Mansoor accepted job',
            completed: true,
          ),
          _buildStep(
            number: '03',
            title: 'Job In Progress',
            subtitle: 'Coil cleaning & pressure test',
            completed: true,
            isCurrent: true,
          ),
          _buildStep(
            number: '04',
            title: 'Service Completed',
            subtitle: 'Final inspection & sign-off',
            completed: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String subtitle,
    required bool completed,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? LandingTheme.gold
                      : (completed
                          ? const Color(0xFF061A3D)
                          : const Color(0xFFCBD5E1)),
                  border: isCurrent
                      ? Border.all(color: const Color(0xFF061A3D), width: 2)
                      : null,
                ),
                child: Center(
                  child: completed
                      ? const Icon(Icons.check, color: Colors.white, size: 11)
                      : Text(
                          number,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 7.5),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: completed
                        ? const Color(0xFF061A3D)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight:
                          isCurrent ? FontWeight.w800 : FontWeight.w700,
                      color: isCurrent
                          ? const Color(0xFF0B3A8C)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 7.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 5. SCREEN: NOTIFICATIONS
// -------------------------------------------------------------
class _NotificationsScreenView extends StatelessWidget {
  const _NotificationsScreenView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(14, 38, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Flexible(
                child: Text(
                  'Notifications',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF061A3D),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Text(
                'Mark All Read',
                style: TextStyle(
                  color: Color(0xFF0B3A8C),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildNotificationItem(
            icon: Icons.assignment_turned_in,
            iconBg: const Color(0xFF061A3D),
            iconColor: LandingTheme.gold,
            title: 'Service Request Received',
            message: 'Your AC service request #AT-8842 has been logged.',
            time: '2m ago',
          ),
          const SizedBox(height: 8),
          _buildNotificationItem(
            icon: Icons.engineering,
            iconBg: const Color(0xFF0B3A8C),
            iconColor: Colors.white,
            title: 'Technician Assigned',
            message: 'Tariq Mansoor is scheduled for your service.',
            time: '12m ago',
          ),
          const SizedBox(height: 8),
          _buildNotificationItem(
            icon: Icons.directions_car,
            iconBg: const Color(0xFFE8F1FC),
            iconColor: const Color(0xFF0B3A8C),
            title: 'Technician on the Way',
            message: 'Estimated arrival in 15 minutes at your location.',
            time: '25m ago',
          ),
          const SizedBox(height: 8),
          _buildNotificationItem(
            icon: Icons.verified,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
            title: 'Service Completed',
            message: 'Cooling system inspection signed off successfully.',
            time: 'Yesterday',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 7.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
