import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customer/services/booking_service.dart';
import '../customer/services/chat_service.dart';
import '../customer/theme/app_theme.dart';
import 'admin_chat_list_screen.dart';
import 'admin_navigation_drawer.dart';
import 'admin_requests_screen.dart';
import 'admin_theme.dart';
import 'admin_web_login_screen.dart';

class AdminWebDashboardScreen extends StatefulWidget {
  const AdminWebDashboardScreen({super.key});

  @override
  State<AdminWebDashboardScreen> createState() =>
      _AdminWebDashboardScreenState();
}

class _AdminWebDashboardScreenState extends State<AdminWebDashboardScreen> {
  final BookingService _bookingService = BookingService();
  final ChatService _chatService = ChatService();
  String _range = '7 Days';

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AdminWebLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingRequest>>(
      stream: _bookingService.watchBookings(),
      builder: (context, requestSnapshot) {
        final requests = requestSnapshot.data ?? const <BookingRequest>[];
        return StreamBuilder<List<TechnicianProfile>>(
          stream: _bookingService.watchTechnicians(),
          builder: (context, technicianSnapshot) {
            final technicians =
                technicianSnapshot.data ?? const <TechnicianProfile>[];
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              drawer: const AdminNavigationDrawer(),
              appBar: AdminGradientAppBar(
                title: 'Dashboard',
                subtitle:
                    "Here's what's happening with your HVAC services today.",
                actions: [
                  StreamBuilder<List<ChatConversation>>(
                    stream: _chatService.watchAllChats(),
                    builder: (context, chatSnap) {
                      final unread = (chatSnap.data ?? []).fold<int>(
                        0,
                        (sum, c) => sum + c.unreadByAdminCount,
                      );
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AdminChatListScreen(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.chat_outlined,
                              color: Colors.white,
                            ),
                            tooltip: 'Customer Chats',
                          ),
                          if (unread > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: gold,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: navy,
                                    width: 1.5,
                                  ),
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
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications.')),
                    ),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Notifications',
                  ),
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: const Icon(
                      Icons.logout_outlined,
                      color: Colors.white,
                    ),
                    tooltip: 'Logout',
                  ),
                ],
              ),
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final padding = constraints.maxWidth >= 1200 ? 28.0 : 18.0;
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(padding, 24, padding, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeaderRange(
                            range: _range,
                            onChanged: (value) =>
                                setState(() => _range = value),
                          ),
                          const SizedBox(height: 18),
                          _MetricGrid(requests: requests),
                          const SizedBox(height: 20),
                          _MiddleSection(
                            requests: requests,
                            range: _range,
                            onRangeChanged: (value) =>
                                setState(() => _range = value),
                            onViewRequests: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AdminRequestsScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _BottomSection(
                            requests: requests,
                            technicians: technicians,
                            onViewRequests: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AdminRequestsScreen(),
                              ),
                            ),
                          ),
                          if (requestSnapshot.hasError ||
                              technicianSnapshot.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                'Live data warning: ${requestSnapshot.error ?? technicianSnapshot.error}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HeaderRange extends StatelessWidget {
  const _HeaderRange({required this.range, required this.onChanged});
  final String range;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _cardDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: range,
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: navy,
              ),
              items: const ['7 Days', '30 Days', 'This Month']
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.requests});
  final List<BookingRequest> requests;

  @override
  Widget build(BuildContext context) {
    final pending = requests
        .where((request) => _isPending(request.status))
        .length;
    final confirmed = requests
        .where((request) => request.status.toLowerCase() == 'confirmed')
        .length;
    final completed = requests
        .where((request) => request.status.toLowerCase() == 'completed')
        .length;
    final cards = [
      _MetricCard(
        title: 'Total Requests',
        value: '${requests.length}',
        trend: '+33%',
        color: const Color(0xFF1683EE),
        icon: Icons.description_outlined,
        values: const [2, 3, 2, 4, 3, 5, 6],
      ),
      _MetricCard(
        title: 'Pending Requests',
        value: '$pending',
        trend: '+100%',
        color: const Color(0xFFF59E0B),
        icon: Icons.schedule_outlined,
        values: const [1, 2, 1, 3, 3, 4, 5],
      ),
      _MetricCard(
        title: 'Confirmed Requests',
        value: '$confirmed',
        trend: '+20%',
        color: const Color(0xFF22A35A),
        icon: Icons.check_circle_outline,
        values: const [1, 3, 2, 3, 4, 4, 5],
      ),
      _MetricCard(
        title: 'Completed Requests',
        value: '$completed',
        trend: '+100%',
        color: const Color(0xFF7356E8),
        icon: Icons.verified_outlined,
        values: const [1, 1, 2, 2, 3, 3, 4],
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: columns == 1 ? 3.1 : 2.2,
          children: cards,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
    required this.icon,
    required this.values,
  });
  final String title;
  final String value;
  final String trend;
  final Color color;
  final IconData icon;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$trend vs. last 7 days',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 82,
            height: 42,
            child: CustomPaint(
              painter: _SparklinePainter(color: color, values: values),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiddleSection extends StatelessWidget {
  const _MiddleSection({
    required this.requests,
    required this.range,
    required this.onRangeChanged,
    required this.onViewRequests,
  });
  final List<BookingRequest> requests;
  final String range;
  final ValueChanged<String> onRangeChanged;
  final VoidCallback onViewRequests;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final activity = _ActivityCard(
          range: range,
          onRangeChanged: onRangeChanged,
        );
        final right = Column(
          children: [
            Expanded(child: _StatusCard(requests: requests)),
            const SizedBox(height: 16),
            Expanded(child: _QuickActions(onViewRequests: onViewRequests)),
          ],
        );
        if (constraints.maxWidth < 850) {
          return Column(
            children: [
              SizedBox(height: 320, child: activity),
              const SizedBox(height: 16),
              SizedBox(height: 500, child: right),
            ],
          );
        }
        return SizedBox(
          height: 390,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 7, child: activity),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: right),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.range, required this.onRangeChanged});
  final String range;
  final ValueChanged<String> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Request Activity',
                  style: TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: ['7 Days', '30 Days', 'This Month']
                    .map((value) {
                      final selected = range == value;
                      return ChoiceChip(
                        label: Text(
                          value,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : navy,
                          ),
                        ),
                        selected: selected,
                        onSelected: (_) => onRangeChanged(value),
                        selectedColor: navy,
                        backgroundColor: const Color(0xFFF1F5F9),
                        showCheckmark: false,
                        side: BorderSide(
                          color: selected ? navy : const Color(0xFFCBD5E1),
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    })
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Expanded(
            child: CustomPaint(
              painter: _ActivityPainter(),
              child: SizedBox.expand(),
            ),
          ),
          const Wrap(
            spacing: 14,
            children: [
              _Legend(color: Color(0xFFFBBF24), label: 'New'),
              _Legend(color: Color(0xFFF97316), label: 'Pending'),
              _Legend(color: Color(0xFF1683EE), label: 'Confirmed'),
              _Legend(color: Color(0xFF22A35A), label: 'Completed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.requests});
  final List<BookingRequest> requests;

  @override
  Widget build(BuildContext context) {
    final pending = requests
        .where((request) => _isPending(request.status))
        .length;
    final confirmed = requests
        .where((request) => request.status.toLowerCase() == 'confirmed')
        .length;
    final completed = requests
        .where((request) => request.status.toLowerCase() == 'completed')
        .length;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Status',
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 125,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      values: [
                        1,
                        pending.toDouble(),
                        confirmed.toDouble(),
                        completed.toDouble(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatusLine(
                        color: const Color(0xFFFBBF24),
                        label: 'New',
                        value: '1',
                      ),
                      _StatusLine(
                        color: const Color(0xFFF97316),
                        label: 'Pending',
                        value: '$pending',
                      ),
                      _StatusLine(
                        color: const Color(0xFF1683EE),
                        label: 'Confirmed',
                        value: '$confirmed',
                      ),
                      _StatusLine(
                        color: const Color(0xFF22A35A),
                        label: 'Completed',
                        value: '$completed',
                      ),
                    ],
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onViewRequests});
  final VoidCallback onViewRequests;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              icon: Icons.add,
              label: 'Add New Request',
              onPressed: () {},
            ),
            _ActionButton(
              icon: Icons.person_add_alt_1_outlined,
              label: 'Assign Technician',
              onPressed: onViewRequests,
            ),
            _ActionButton(
              icon: Icons.description_outlined,
              label: 'View All Requests',
              onPressed: onViewRequests,
            ),
            _ActionButton(
              icon: Icons.bar_chart_rounded,
              label: 'Generate Report',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.requests,
    required this.technicians,
    required this.onViewRequests,
  });
  final List<BookingRequest> requests;
  final List<TechnicianProfile> technicians;
  final VoidCallback onViewRequests;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final recent = _RecentRequests(
          requests: requests,
          onViewRequests: onViewRequests,
        );
        final side = Column(
          children: [
            Expanded(child: _TechnicianAvailability(technicians: technicians)),
            const SizedBox(height: 16),
            Expanded(
              child: _QuickStats(
                technicianCount: technicians.length,
                assignments: requests
                    .where((r) => (r.technicianUid ?? '').isNotEmpty)
                    .length,
              ),
            ),
          ],
        );
        if (constraints.maxWidth < 850) {
          return Column(
            children: [
              SizedBox(height: 430, child: recent),
              const SizedBox(height: 16),
              SizedBox(height: 650, child: side),
            ],
          );
        }
        return SizedBox(
          height: 475,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 65, child: recent),
              const SizedBox(width: 16),
              Expanded(flex: 35, child: side),
            ],
          ),
        );
      },
    );
  }
}

class _RecentRequests extends StatelessWidget {
  const _RecentRequests({required this.requests, required this.onViewRequests});
  final List<BookingRequest> requests;
  final VoidCallback onViewRequests;

  @override
  Widget build(BuildContext context) {
    final recent = requests.take(5).toList();
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Requests',
                  style: TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewRequests,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: recent.isEmpty
                ? const Center(
                    child: Text(
                      'No booking requests yet.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: const WidgetStatePropertyAll(
                        Color(0xFFF1F5F9),
                      ),
                      headingTextStyle: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      dataTextStyle: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      columnSpacing: 18,
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Customer Name')),
                        DataColumn(label: Text('Service Type')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Technician')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: recent.asMap().entries.map((entry) {
                        final request = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Text('${entry.key + 1}')),
                            DataCell(Text(request.customerName)),
                            DataCell(Text(request.serviceName)),
                            DataCell(_StatusBadge(status: request.status)),
                            DataCell(
                              Text(
                                request.technicianName?.isNotEmpty == true
                                    ? request.technicianName!
                                    : '-',
                              ),
                            ),
                            DataCell(
                              Text(
                                request.preferredDate.isEmpty
                                    ? '-'
                                    : request.preferredDate,
                              ),
                            ),
                            DataCell(
                              IconButton(
                                onPressed: onViewRequests,
                                icon: const Icon(Icons.more_vert, size: 18),
                                tooltip: 'View request',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TechnicianAvailability extends StatelessWidget {
  const _TechnicianAvailability({required this.technicians});
  final List<TechnicianProfile> technicians;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Technician Availability',
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: technicians.isEmpty
                ? const Center(
                    child: Text(
                      'No registered technicians.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  )
                : ListView.separated(
                    itemCount: technicians.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final technician = technicians[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: navy,
                          child: Text(
                            technician.name.isEmpty
                                ? '?'
                                : technician.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          technician.name,
                          style: const TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          technician.email.isEmpty
                              ? 'Technician'
                              : technician.email,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                          ),
                        ),
                        trailing: const _AvailabilityBadge(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.technicianCount, required this.assignments});
  final int technicianCount;
  final int assignments;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                color: navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _QuickStat(
              icon: Icons.people_alt_outlined,
              label: 'Total Technicians',
              value: '$technicianCount',
              color: const Color(0xFF1683EE),
            ),
            _QuickStat(
              icon: Icons.bolt_outlined,
              label: 'Active Today',
              value: '$technicianCount',
              color: const Color(0xFFF59E0B),
            ),
            const _QuickStat(
              icon: Icons.event_busy_outlined,
              label: 'On Leave',
              value: '0',
              color: Color(0xFFEF4444),
            ),
            _QuickStat(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Assignments',
              value: '$assignments',
              color: const Color(0xFF22A35A),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: child,
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 17),
          label: Align(alignment: Alignment.centerLeft, child: Text(label)),
          style: OutlinedButton.styleFrom(
            foregroundColor: navy,
            alignment: Alignment.centerLeft,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            backgroundColor: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: navy,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'completed'
        ? const Color(0xFF22A35A)
        : normalized == 'confirmed'
        ? const Color(0xFF1683EE)
        : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'New' : status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFDCFCE7),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      'Available',
      style: TextStyle(
        color: Color(0xFF15803D),
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

bool _isPending(String status) {
  final normalized = status.toLowerCase();
  return normalized == 'pending' || normalized == 'assigned';
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFE2E8F0)),
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: navy.withValues(alpha: .04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.color, required this.values});
  final Color color;
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    final max = values.reduce((a, b) => a > b ? a : b);
    for (var i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - (values[i] / max * size.height * .8) - 3;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _ActivityPainter extends CustomPainter {
  const _ActivityPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final sets = [
      [6, 8, 5, 6, 5, 8, 6],
      [3, 4, 2, 3, 2, 3, 2],
      [4, 6, 4, 5, 4, 6, 4],
      [1, 2, 1, 1, 1, 2, 1],
    ];
    final colors = [
      const Color(0xFFFBBF24),
      const Color(0xFFF97316),
      const Color(0xFF1683EE),
      const Color(0xFF22A35A),
    ];
    for (var s = 0; s < sets.length; s++) {
      final paint = Paint()
        ..color = colors[s]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (var i = 0; i < sets[s].length; i++) {
        final x = i * size.width / 6;
        final y = size.height - (sets[s][i] / 10 * size.height);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityPainter oldDelegate) => false;
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.values});
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    var start = -1.57;
    final colors = [
      const Color(0xFFFBBF24),
      const Color(0xFFF97316),
      const Color(0xFF1683EE),
      const Color(0xFF22A35A),
    ];
    for (var i = 0; i < values.length; i++) {
      final sweep = total == 0 ? 0.0 : values[i] / total * 6.28;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22;
      canvas.drawArc(Offset.zero & size, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values;
}
