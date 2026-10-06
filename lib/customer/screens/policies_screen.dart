import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/customer_page_chrome.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  static const _policies = [
    _PolicyData(
      'Service Commitment',
      'Our technicians provide professional HVAC service with care, clear communication, and attention to your property.',
      Icons.handshake_outlined,
    ),
    _PolicyData(
      'Booking & Appointments',
      'Appointments are confirmed according to technician availability. Please provide accurate access details when booking.',
      Icons.calendar_month_outlined,
    ),
    _PolicyData(
      'Equipment & Warranty',
      'We use quality equipment from trusted suppliers. Manufacturer warranties apply according to each product\'s terms.',
      Icons.verified_outlined,
    ),
    _PolicyData(
      'Cancellation Policy',
      'Please contact us as early as possible if you need to change or cancel an appointment so we can help promptly.',
      Icons.event_busy_outlined,
    ),
    _PolicyData(
      'Privacy & Data',
      'Your contact and service information is used to provide, support, and improve your Al-Taqwa experience.',
      Icons.lock_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    body: Stack(
      children: [
        const Positioned.fill(child: CustomerPageBackground()),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              children: [
                const CustomerPageHeader(
                  eyebrow: 'AL TAQWA  /  CUSTOMER',
                  title: 'Policies',
                  subtitle: 'Clear guidelines for your peace of mind.',
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: navy,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: navy.withValues(alpha: 0.16),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: goldLight,
                              size: 22,
                            ),
                            SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                'We keep every service straightforward, professional, and focused on your comfort.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      ..._policies.map(
                        (policy) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PolicyCard(data: policy),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Center(
                        child: Text(
                          'Questions about a policy? Contact the Al-Taqwa team.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: navy.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You are all caught up.')),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.data});

  final _PolicyData data;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE3E7EB)),
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: 0.09),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.17),
            shape: BoxShape.circle,
          ),
          child: Icon(data.icon, color: navy, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.description,
                style: const TextStyle(
                  color: Color(0xFF5E6874),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PolicyData {
  const _PolicyData(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}
