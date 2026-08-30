import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/policies_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/services_screen.dart';
import '../theme/app_theme.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, this.currentIndex = 0});

  final int currentIndex;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 12,
    shadowColor: navy.withValues(alpha: 0.2),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: currentIndex == 0,
              onTap: () => _replaceWith(context, const HomeScreen()),
            ),
            _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'Services',
              active: currentIndex == 1,
              onTap: () => _replaceWith(context, const ServicesScreen()),
            ),
            _NavItem(
              icon: Icons.phone_outlined,
              label: 'Call Us',
              callAction: true,
              onTap: () => _showMessage(context, 'Calling Al-Taqwa...'),
            ),
            _NavItem(
              icon: Icons.shield_outlined,
              label: 'Policies',
              active: currentIndex == 3,
              onTap: () => _replaceWith(context, const PoliciesScreen()),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              active: currentIndex == 4,
              onTap: () => _replaceWith(context, const ProfileScreen()),
            ),
          ],
        ),
      ),
    ),
  );

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static void _replaceWith(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, secondaryAnimation) => screen,
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.callAction = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool callAction;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 76,
        child: callAction
            ? Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -19,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: navy,
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: goldLight,
                        size: 24,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 8,
                    child: Text(
                      'Call Us',
                      style: TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: active ? gold : const Color(0xFF3F4A56),
                    size: 23,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: active ? gold : const Color(0xFF3F4A56),
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}
