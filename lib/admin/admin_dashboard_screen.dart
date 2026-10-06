import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customer/services/booking_service.dart';
import '../customer/theme/app_theme.dart';
import 'admin_requests_screen.dart';
import 'admin_theme.dart';
import 'customers_screen.dart';
import '../customer/screens/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, this.bookingService});

  final BookingService? bookingService;

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      const _StatCard(
        title: 'Total Customers',
        value: '128',
        icon: Icons.people_alt_outlined,
      ),
      const _StatCard(
        title: 'Total Technicians',
        value: '18',
        icon: Icons.engineering_outlined,
      ),
      _StatCard(
        title: 'Pending Appointments',
        value: '24',
        icon: Icons.pending_actions_outlined,
        color: Colors.orange.shade700,
      ),
      _StatCard(
        title: 'Scheduled Appointments',
        value: '16',
        icon: Icons.calendar_month_outlined,
        color: Colors.blue.shade700,
      ),
      _StatCard(
        title: 'Completed Jobs',
        value: '94',
        icon: Icons.check_circle_outline,
        color: Colors.green.shade700,
      ),
      _StatCard(
        title: 'Cancelled Appointments',
        value: '7',
        icon: Icons.cancel_outlined,
        color: Colors.red.shade700,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 73, 123, 172),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(gradient: _adminDrawerGradient),
                child: const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.people_alt_outlined, color: navy),
                title: const Text(
                  'Customers',
                  style: TextStyle(color: navy, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CustomersScreen(
                        bookingService: bookingService ?? BookingService(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.request_page_outlined, color: navy),
                title: const Text(
                  'Requests',
                  style: TextStyle(color: navy, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminRequestsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined, color: navy),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: navy, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AdminGradientAppBar(
        title: 'Admin Dashboard',
        subtitle: 'Operations overview and customer activity.',
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Operations overview',
                style: TextStyle(
                  color: navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.42,
                children: stats,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3B0),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color = navy,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3B0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE7D57A).withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF5E6874),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

const _adminDrawerGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [navyDeep, navy, Color(0xFF173A6A)],
);
