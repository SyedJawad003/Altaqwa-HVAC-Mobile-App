import 'package:flutter/material.dart';

import '../customer/services/booking_service.dart';
import '../customer/theme/app_theme.dart';
import 'admin_chat_list_screen.dart';
import 'admin_chat_screen.dart';
import 'admin_navigation_drawer.dart';
import 'admin_requests_screen.dart';
import 'admin_theme.dart';

class CustomersScreen extends StatelessWidget {
  CustomersScreen({super.key, BookingService? bookingService})
    : bookingService = bookingService ?? BookingService();

  final BookingService bookingService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AdminNavigationDrawer(),
      appBar: const AdminGradientAppBar(
        title: 'Customers',
        subtitle: 'Customer activity and booking history.',
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: navy.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Activity',
                          style: TextStyle(
                            color: navy,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const AdminRequestsScreen(),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: gold,
                                  foregroundColor: navy,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Open Requests'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const AdminChatListScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_outlined, size: 18),
                                label: const Text('Customer Chats'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: navy,
                                  side: const BorderSide(color: navy),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: StreamBuilder<List<BookingRequest>>(
                      stream: bookingService.watchBookings(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: navy),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Unable to load customer bookings.\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: navy,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }

                        final requests = snapshot.data ?? const <BookingRequest>[];

                        if (requests.isEmpty) {
                          return const Center(
                            child: Text(
                              'No customer bookings found.',
                              style: TextStyle(
                                color: navy,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: requests.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            final customerName = request.customerName.trim().isEmpty
                                ? 'Unknown Customer'
                                : request.customerName;
                            final serviceName = request.serviceName.trim().isEmpty
                                ? 'HVAC Service'
                                : request.serviceName;
                            final date = request.preferredDate.trim().isEmpty
                                ? 'Date not set'
                                : request.preferredDate;
                            final time = request.preferredTime.trim().isEmpty
                                ? 'Time not set'
                                : request.preferredTime;

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: navy.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFE3E8F0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [navy.withValues(alpha: 0.88), const Color(0xFF15263D)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: navy.withValues(alpha: 0.18),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: goldLight,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                customerName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: navy,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '$serviceName • $date • $time',
                                          style: const TextStyle(
                                            color: Color(0xFF667085),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          request.address.isEmpty
                                              ? 'Address not provided'
                                              : request.address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF667085),
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.chat_bubble_outline,
                                      color: navy,
                                    ),
                                    tooltip: 'Chat with $customerName',
                                    onPressed: () {
                                      final cid = request.customerUid?.isNotEmpty == true
                                          ? request.customerUid!
                                          : 'cust_${request.id}';
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => AdminChatScreen(
                                            chatId: 'chat_$cid',
                                            customerId: cid,
                                            customerName: customerName,
                                            customerEmail: request.customerEmail,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
