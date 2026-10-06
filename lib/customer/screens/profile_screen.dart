flutter run -t lib/main_admin.dartimport 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_page_route.dart';
import '../widgets/customer_page_chrome.dart';
import 'login_screen.dart';
import 'policies_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String get _name {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    return user?.email?.split('@').first ?? 'Al Taqwa Customer';
  }

  String get _email =>
      FirebaseAuth.instance.currentUser?.email ?? 'Email not available';

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      appPageRoute<void>(const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    bottomNavigationBar: const AppBottomNavigation(currentIndex: 4),
    body: Stack(
      children: [
        const Positioned.fill(child: CustomerPageBackground()),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              children: [
                const CustomerPageHeader(
                  eyebrow: 'AL TAQWA  /  ACCOUNT',
                  title: 'My Profile',
                  subtitle: 'Manage your Al-Taqwa account.',
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(name: _name, email: _email),
                      const SizedBox(height: 20),
                      const _ProfileSectionTitle('Account'),
                      const SizedBox(height: 9),
                      _ProfileTile(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        subtitle: 'View and update your account details',
                        onTap: () => _showMessage(
                          context,
                          'Personal information selected.',
                        ),
                      ),
                      const SizedBox(height: 9),
                      _ProfileTile(
                        icon: Icons.history_outlined,
                        title: 'Service History',
                        subtitle: 'Review your HVAC service requests',
                        onTap: () =>
                            _showMessage(context, 'Service history selected.'),
                      ),
                      const SizedBox(height: 20),
                      const _ProfileSectionTitle('Support'),
                      const SizedBox(height: 9),
                      _ProfileTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get assistance from our team',
                        onTap: () => _showMessage(
                          context,
                          'Our support team is ready to help.',
                        ),
                      ),
                      const SizedBox(height: 9),
                      _ProfileTile(
                        icon: Icons.shield_outlined,
                        title: 'Privacy & Policies',
                        subtitle: 'Read our service policies',
                        onTap: () => Navigator.of(context)
                            .push(appPageRoute<void>(const PoliciesScreen())),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout_outlined, size: 19),
                          label: const Text('Log Out'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            foregroundColor: const Color(0xFFB3261E),
                            side: const BorderSide(color: Color(0xFFB3261E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 16,
          child: SafeArea(
            child: CustomerPageNotificationButton(
              onPressed: () => _showMessage(context, 'You are all caught up.'),
            ),
          ),
        ),
      ],
    ),
  );

  static void _showMessage(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: navy,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: navy,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFD8E0EA), fontSize: 11),
              ),
              const SizedBox(height: 5),
              const Text(
                'Al-Taqwa customer',
                style: TextStyle(
                  color: goldLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        width: 30,
        height: 3,
        decoration: BoxDecoration(
          color: gold,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ],
  );
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    elevation: 1.5,
    shadowColor: navy.withValues(alpha: 0.14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: navy, size: 20),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF5E6874),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: gold, size: 21),
          ],
        ),
      ),
    ),
  );
}
