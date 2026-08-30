import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.userName});

  final String? userName;

  String get _displayName {
    final name = userName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final user = FirebaseAuth.instance.currentUser;
    final firebaseName = user?.displayName?.trim();
    if (firebaseName != null && firebaseName.isNotEmpty) return firebaseName;
    return user?.email?.split('@').first ?? 'Ahmad';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/home_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 108, 66, 0),
                child: _WelcomeHeader(userName: _displayName),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: ClipRect(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MaintenanceCard(
                          onPressed: () => _showMessage(
                            context,
                            'Maintenance booking selected.',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _RequestsCard(),
                        const SizedBox(height: 16),
                        _ServicePlanCard(
                          onPressed: () => _showMessage(
                            context,
                            'Service plan selected.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: _NotificationButton(
                onPressed: () => _showMessage(context, 'You are all caught up.'),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 48),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(color: goldLight, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '$userName!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            const Text(
              "We're here to keep your environment cool and comfortable.",
              style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.35),
            ),
          ],
        ),
  );
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Notifications',
    onPressed: onPressed,
    icon: Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none, color: Colors.white, size: 27),
        Positioned(
          top: -1,
          right: -2,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
          ),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.w800)),
      TextButton.icon(
        onPressed: () => HomeScreen._showMessage(context, 'Showing all $title.'),
        icon: const Icon(Icons.arrow_forward, size: 15),
        label: const Text('View All'),
        style: TextButton.styleFrom(
          foregroundColor: gold,
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: navy.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 5))],
    ),
    child: child,
  );
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: navy,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: navy.withValues(alpha: 0.2), blurRadius: 14, offset: const Offset(0, 5))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Keep Your System', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
        const Text('Running Perfectly', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text(
          'Regular maintenance ensures better performance and energy savings.',
          style: TextStyle(color: Color(0xFFDCE5F0), fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          child: const Text('Book Maintenance'),
        ),
      ],
    ),
  );
}

class _RequestsCard extends StatelessWidget {
  const _RequestsCard();

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      children: const [
        _SectionHeading(title: 'My Requests'),
        SizedBox(height: 4),
        _RequestItem(
          icon: Icons.ac_unit_outlined,
          title: 'AC Installation',
          requestId: 'Request ID: #1024',
          date: '20 May 2024 | 10:30 AM',
          status: 'Completed',
          statusColor: Color(0xFFE3F4E8),
          statusTextColor: Color(0xFF287B43),
        ),
        Divider(height: 20, color: Color(0xFFE8ECF1)),
        _RequestItem(
          icon: Icons.build_outlined,
          title: 'AC Repair',
          requestId: 'Request ID: #1027',
          date: '22 May 2024 | 02:15 PM',
          status: 'In Progress',
          statusColor: Color(0xFFE5F0FF),
          statusTextColor: Color(0xFF2467A8),
        ),
      ],
    ),
  );
}

class _RequestItem extends StatelessWidget {
  const _RequestItem({
    required this.icon,
    required this.title,
    required this.requestId,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
  });

  final IconData icon;
  final String title;
  final String requestId;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusTextColor;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => HomeScreen._showMessage(context, '$title details selected.'),
    borderRadius: BorderRadius.circular(12),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: const Color(0xFFFFF8E7), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: navy, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(requestId, style: const TextStyle(color: Color(0xFF657180), fontSize: 11)),
              const SizedBox(height: 2),
              Text(date, style: const TextStyle(color: Color(0xFF657180), fontSize: 10)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusBadge(label: status, backgroundColor: statusColor, textColor: statusTextColor),
            const SizedBox(height: 8),
            const Icon(Icons.chevron_right, color: gold, size: 22),
          ],
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.backgroundColor, required this.textColor});

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(7)),
    child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

class _ServicePlanCard extends StatelessWidget {
  const _ServicePlanCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F6FB),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFDCE7F1)),
    ),
    child: Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shield_outlined, color: navy, size: 29),
              Positioned(right: 7, bottom: 8, child: Icon(Icons.check_circle, color: gold, size: 14)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Service Plan', style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Silver Plan • Valid till 20 Dec 2024', style: TextStyle(color: Color(0xFF657180), fontSize: 11)),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: navy,
            side: const BorderSide(color: navy),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          child: const Text('View Plan'),
        ),
      ],
    ),
  );
}
