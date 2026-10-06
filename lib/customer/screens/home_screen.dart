import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'customer_chat_screen.dart';
import 'get_quote_screen.dart';
import '../services/booking_service.dart';
import '../services/chat_service.dart';
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
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CustomerChatScreen()),
        );
      },
      backgroundColor: navy,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: gold, width: 1.5),
      ),
      icon: const Icon(Icons.support_agent_rounded, color: gold, size: 22),
      label: const Text(
        'Live Support',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    ),
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
                        const _CustomerQuotationsCard(),
                        const SizedBox(height: 16),
                        _ServicePlanCard(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const GetQuoteScreen(),
                              ),
                            );
                          },
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ChatButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CustomerChatScreen(),
                        ),
                      );
                    },
                  ),
                  _NotificationButton(
                    onPressed: () =>
                        _showMessage(context, 'You are all caught up.'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          style: TextStyle(
            color: goldLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$userName!',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          "We're here to keep your environment cool and comfortable.",
          style: TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final chatId = user != null ? ChatService.getChatId(user.uid) : null;

    return StreamBuilder<ChatConversation?>(
      stream: chatId != null
          ? ChatService().watchChatConversation(chatId)
          : null,
      builder: (context, snapshot) {
        final unread = snapshot.data?.unreadByCustomerCount ?? 0;
        return IconButton(
          tooltip: 'Live Support Chat',
          onPressed: onPressed,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_outlined, color: Colors.white, size: 25),
              if (unread > 0)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: navy, width: 1.5),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
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
            decoration: const BoxDecoration(
              color: gold,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      TextButton.icon(
        onPressed:
            onViewAll ??
            () => HomeScreen._showMessage(context, 'Showing all $title.'),
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
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
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
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: 0.2),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keep Your System',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          'Running Perfectly',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Regular maintenance ensures better performance and energy savings.',
          style: TextStyle(
            color: Color(0xFFDCE5F0),
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
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
      children: [
        _SectionHeading(
          title: 'My Requests',
          onViewAll: () =>
              HomeScreen._showMessage(context, 'Showing all requests.'),
        ),
        const SizedBox(height: 4),
        _RequestItem(
          icon: Icons.ac_unit_outlined,
          title: 'AC Installation',
          requestId: 'Request ID: #1024',
          requestCode: '1024',
          date: '20 May 2024 | 10:30 AM',
          status: 'Completed',
          statusColor: const Color(0xFFE3F4E8),
          statusTextColor: const Color(0xFF287B43),
        ),
        const Divider(height: 20, color: Color(0xFFE8ECF1)),
        _RequestItem(
          icon: Icons.build_outlined,
          title: 'AC Repair',
          requestId: 'Request ID: #1027',
          requestCode: '1027',
          date: '22 May 2024 | 02:15 PM',
          status: 'In Progress',
          statusColor: const Color(0xFFE5F0FF),
          statusTextColor: const Color(0xFF2467A8),
        ),
      ],
    ),
  );
}

class _CustomerQuotationsCard extends StatelessWidget {
  const _CustomerQuotationsCard();

  @override
  Widget build(BuildContext context) {
    final customerUid = FirebaseAuth.instance.currentUser?.uid;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Quotations',
            style: TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (customerUid == null)
            const Text(
              'Sign in to view quotations sent to you.',
              style: TextStyle(color: Color(0xFF657180), fontSize: 12),
            )
          else
            StreamBuilder<List<Quotation>>(
              stream: BookingService().watchCustomerQuotations(customerUid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Could not load your quotations: ${snapshot.error}',
                    style: const TextStyle(
                      color: Color(0xFF657180),
                      fontSize: 12,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final quotations = snapshot.data ?? const <Quotation>[];
                if (quotations.isEmpty) {
                  return const Text(
                    'Quotations sent by our team will appear here.',
                    style: TextStyle(color: Color(0xFF657180), fontSize: 12),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < quotations.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 18, color: Color(0xFFE8ECF1)),
                      _CustomerQuotationItem(quotation: quotations[i]),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CustomerQuotationItem extends StatelessWidget {
  const _CustomerQuotationItem({required this.quotation});

  final Quotation quotation;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.receipt_long_rounded, color: navy, size: 21),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quotation.serviceName.isEmpty
                  ? 'Service quotation'
                  : quotation.serviceName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${quotation.quotationNumber} • AED ${quotation.totalAmount.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF657180), fontSize: 10),
            ),
          ],
        ),
      ),
      const SizedBox(width: 4),
      TextButton.icon(
        onPressed: () async {
          final bytes = quotation.pdfBytes;
          if (bytes == null || bytes.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'This quotation does not have a stored PDF file.',
                  ),
                ),
              );
            }
            return;
          }
          try {
            await Printing.layoutPdf(
              onLayout: (_) async => bytes,
              name: '${quotation.quotationNumber}.pdf',
            );
          } catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open quotation PDF: $error')),
              );
            }
          }
        },
        icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
        label: const Text('View'),
        style: TextButton.styleFrom(
          foregroundColor: navy,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}

class _RequestItem extends StatelessWidget {
  const _RequestItem({
    required this.icon,
    required this.title,
    required this.requestId,
    required this.requestCode,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
  });

  final IconData icon;
  final String title;
  final String requestId;
  final String requestCode;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusTextColor;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _showRequestDetailSheet(context),
    borderRadius: BorderRadius.circular(12),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: navy, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                requestId,
                style: const TextStyle(color: Color(0xFF657180), fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(color: Color(0xFF657180), fontSize: 10),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusBadge(
              label: status,
              backgroundColor: statusColor,
              textColor: statusTextColor,
            ),
            const SizedBox(height: 8),
            const Icon(Icons.chevron_right, color: gold, size: 22),
          ],
        ),
      ],
    ),
  );

  void _showRequestDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: navy.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: navy, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          requestId,
                          style: const TextStyle(
                            color: Color(0xFF657180),
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Color(0xFF657180),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: status,
                    backgroundColor: statusColor,
                    textColor: statusTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE8ECF1)),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    HomeScreen._showMessage(
                      context,
                      'Opening $title details...',
                    );
                  },
                  icon: const Icon(Icons.info_outline_rounded, size: 17),
                  label: const Text('View Full Details'),
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: goldLight,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
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
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F2744), Color(0xFF1E5A9C), gold],
        stops: [0, 0.58, 1],
      ),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: 0.18),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
              Positioned(
                right: 5,
                bottom: 6,
                child: Icon(Icons.add_circle, color: gold, size: 15),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request a Free Quote',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Send photos & details, get a tailored estimate.',
                style: TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: const Text('Get a Quote'),
        ),
      ],
    ),
  );
}
