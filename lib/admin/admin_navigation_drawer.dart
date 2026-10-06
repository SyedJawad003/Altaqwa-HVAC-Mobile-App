import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_requests_screen.dart';
import 'admin_supervisor_issues_screen.dart';
import 'admin_technicians_screen.dart';
import 'admin_web_dashboard_screen.dart';
import 'admin_web_login_screen.dart';
import 'customers_screen.dart';
import 'admin_chat_list_screen.dart';
import '../customer/theme/app_theme.dart';

class AdminNavigationDrawer extends StatelessWidget {
  const AdminNavigationDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AdminWebLoginScreen()),
        (route) => false,
      );
    }
  }

  void _open(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              decoration: const BoxDecoration(gradient: _adminDrawerGradient),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      'assets/altaqwa_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.ac_unit, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Admin Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: navy),
              title: const Text(
                'Main dashboard',
                style: TextStyle(color: navy, fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminWebDashboardScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.people_alt_outlined, color: navy),
              title: const Text(
                'Customers',
                style: TextStyle(color: navy, fontWeight: FontWeight.w700),
              ),
              iconColor: navy,
              collapsedIconColor: navy,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  leading: const Icon(
                    Icons.people_outline,
                    color: navy,
                    size: 20,
                  ),
                  title: const Text(
                    'Customers',
                    style: TextStyle(color: navy, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _open(context, CustomersScreen()),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  leading: const Icon(
                    Icons.request_page_outlined,
                    color: navy,
                    size: 20,
                  ),
                  title: const Text(
                    'Requests',
                    style: TextStyle(color: navy, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _open(context, const AdminRequestsScreen()),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  leading: const Icon(
                    Icons.chat_bubble_outline,
                    color: navy,
                    size: 20,
                  ),
                  title: const Text(
                    'Customer Chats',
                    style: TextStyle(color: navy, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _open(context, const AdminChatListScreen()),
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.forum_outlined, color: navy),
              title: const Text(
                'Customer Chats',
                style: TextStyle(color: navy, fontWeight: FontWeight.w700),
              ),
              onTap: () => _open(context, const AdminChatListScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.engineering_outlined, color: navy),
              title: const Text(
                'Technicians',
                style: TextStyle(color: navy, fontWeight: FontWeight.w700),
              ),
              onTap: () => _open(context, AdminTechniciansScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.supervisor_account_outlined, color: navy),
              title: const Text(
                'Supervisors',
                style: TextStyle(color: navy, fontWeight: FontWeight.w700),
              ),
              onTap: () => _open(context, const AdminSupervisorIssuesScreen()),
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
    );
  }

  static const _adminDrawerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navy, Color(0xFF1E5A9C), gold],
    stops: [0, 0.42, 0.78, 1],
  );
}
