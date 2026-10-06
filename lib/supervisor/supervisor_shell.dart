import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customer/services/auth_service.dart';
import '../customer/services/booking_service.dart';
import '../customer/services/job_ops.dart';
import '../customer/theme/app_theme.dart';
import 'supervisor_job_detail.dart';
import 'supervisor_login_screen.dart';
import 'supervisor_pages.dart';
import 'supervisor_widgets.dart';

class SupervisorShell extends StatefulWidget {
  const SupervisorShell({super.key});

  @override
  State<SupervisorShell> createState() => _SupervisorShellState();
}

class _SupervisorShellState extends State<SupervisorShell> {
  int _index = 0;
  bool _allowed = false;
  bool _checking = true;
  String _name = 'Supervisor';

  static const _items = <(IconData, String)>[
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.assignment_outlined, 'Jobs'),
    (Icons.monitor_heart_outlined, 'Monitoring'),
    (Icons.engineering_outlined, 'Technicians'),
    (Icons.report_problem_outlined, 'Issues'),
    (Icons.calendar_month_outlined, 'Schedule'),
    (Icons.bar_chart_rounded, 'Reports'),
    (Icons.receipt_long_rounded, 'Quote Requests'),
    (Icons.notifications_none, 'Notifications'),
  ];

  @override
  void initState() {
    super.initState();
    _guard();
  }

  Future<void> _guard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _sendToLogin();
      return;
    }
    final profile = await AuthService().readUserForRouting(user);
    if (!mounted) return;
    if (profile.role != 'supervisor') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This area is only for supervisors.')),
      );
      _sendToLogin();
      return;
    }
    setState(() {
      _allowed = true;
      _checking = false;
      _name = profile.name;
    });
  }

  void _sendToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SupervisorLoginScreen()),
      (route) => false,
    );
  }

  Future<void> _logout() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log out?'),
            content: const Text('You will leave the Supervisor panel.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Log out'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    _sendToLogin();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking && !_allowed) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: navy)),
      );
    }
    if (!_allowed) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Theme(
      data: supervisorTheme,
      child: StreamBuilder<List<BookingRequest>>(
        stream: BookingService().watchBookings(),
        builder: (context, jobSnapshot) {
          return StreamBuilder<List<TechnicianProfile>>(
            stream: BookingService().watchTechnicians(),
            builder: (context, techSnapshot) {
              final jobs = jobSnapshot.data ?? const <BookingRequest>[];
              final technicians =
                  techSnapshot.data ?? const <TechnicianProfile>[];
              final pages = [
                SupervisorDashboardPage(
                  jobs: jobs,
                  technicians: technicians,
                  loadError: jobSnapshot.error ?? techSnapshot.error,
                  onOpenJob: _openJob,
                  onNavigateTab: (targetIndex) =>
                      setState(() => _index = targetIndex),
                ),
                SupervisorJobsPage(
                  jobs: jobs,
                  loadError: jobSnapshot.error,
                  onOpenJob: _openJob,
                ),
                SupervisorMonitoringPage(
                  jobs: jobs,
                  loadError: jobSnapshot.error,
                  onOpenJob: _openJob,
                ),
                SupervisorTechniciansPage(
                  jobs: jobs,
                  technicians: technicians,
                  loadError: techSnapshot.error,
                ),
                SupervisorIssuesPage(jobs: jobs),
                SupervisorSchedulePage(jobs: jobs, onOpenJob: _openJob),
                SupervisorReportsPage(jobs: jobs, technicians: technicians),
                SupervisorQuoteRequestsPage(
                  service: BookingService(),
                ),
                SupervisorNotificationsPage(
                  uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
              ];
              return LayoutBuilder(
                builder: (context, constraints) {
                  final phone = constraints.maxWidth < 760;
                  final wide = constraints.maxWidth >= 980;
                  return Scaffold(
                    backgroundColor: const Color(0xFFF4F7FB),
                    appBar: SupervisorAppBar(
                      title: _SupervisorShellState._items[_index].$2,
                      subtitle: phone
                          ? null
                          : 'Field operations & job verification',
                      showMenu: true,
                    ),
                    drawer: _Sidebar(
                      name: _name,
                      index: _index,
                      onSelect: (value) {
                        Navigator.pop(context);
                        setState(() => _index = value);
                      },
                      onLogout: _logout,
                    ),
                    body: Row(
                      children: [
                        if (wide)
                          SizedBox(
                            width: 250,
                            child: Material(
                              color: const Color(0xFF07182E),
                              child: _Sidebar(
                                name: _name,
                                index: _index,
                                embedded: true,
                                onSelect: (value) =>
                                    setState(() => _index = value),
                                onLogout: _logout,
                              ),
                            ),
                          ),
                        Expanded(child: pages[_index]),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openJob(BookingRequest job) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SupervisorJobDetailPage(jobId: job.id),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.name,
    required this.index,
    required this.onSelect,
    required this.onLogout,
    this.embedded = false,
  });

  final String name;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: gold.withValues(alpha: 0.22),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Field Supervisor',
                          style: TextStyle(
                            color: gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),
          // Navigation List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: _SupervisorShellState._items.length,
              itemBuilder: (context, itemIndex) {
                final item = _SupervisorShellState._items[itemIndex];
                final selected = index == itemIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: selected
                        ? gold.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: selected
                            ? BorderSide(
                                color: gold.withValues(alpha: 0.4),
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                      leading: Icon(
                        item.$1,
                        color: selected ? gold : Colors.white70,
                        size: 22,
                      ),
                      title: Text(
                        item.$2,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => onSelect(itemIndex),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Logout Tile
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: const Color(0xFFB42318).withValues(alpha: 0.15),
              leading: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFFCA5A5),
                size: 20,
              ),
              title: const Text(
                'Log out',
                style: TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );

    if (embedded) return content;
    return Drawer(
      backgroundColor: const Color(0xFF07182E),
      child: content,
    );
  }
}

class SupervisorDashboardPage extends StatelessWidget {
  const SupervisorDashboardPage({
    super.key,
    required this.jobs,
    required this.technicians,
    required this.onOpenJob,
    this.onNavigateTab,
    this.loadError,
  });

  final List<BookingRequest> jobs;
  final List<TechnicianProfile> technicians;
  final ValueChanged<BookingRequest> onOpenJob;
  final ValueChanged<int>? onNavigateTab;
  final Object? loadError;

  @override
  Widget build(BuildContext context) {
    final attention = jobs
        .where((job) => job.isDelayed || job.needsVerification)
        .toList();

    final completedJobs = jobs
        .where(
          (job) =>
              job.status.toLowerCase() == 'completed' || job.isVerified,
        )
        .length;

    final inProgressJobs = jobs.where((job) => job.isInProgress).length;
    final delayedJobs = jobs.where((job) => job.isDelayed).length;
    final todayJobs = jobs.where((job) => job.isToday).length;
    final pendingActionJobs = jobs.where((job) => job.isPendingAction).length;

    final metrics = [
      (
        'Total jobs',
        '${jobs.length}',
        const Color(0xFF0284C7),
        Icons.inbox_rounded,
        null,
      ),
      (
        "Today's jobs",
        '$todayJobs',
        const Color(0xFF0D9488),
        Icons.today_rounded,
        null,
      ),
      (
        'In progress',
        '$inProgressJobs',
        const Color(0xFF2563EB),
        Icons.handyman_rounded,
        null,
      ),
      (
        'Needs review',
        '${attention.length}',
        const Color(0xFFEA580C),
        Icons.priority_high_rounded,
        attention.isNotEmpty ? 'Action' : null,
      ),
      (
        'Pending',
        '$pendingActionJobs',
        const Color(0xFFD97706),
        Icons.hourglass_top_rounded,
        null,
      ),
      (
        'Completed',
        '$completedJobs',
        const Color(0xFF16A34A),
        Icons.check_circle_rounded,
        null,
      ),
      (
        'Delayed',
        '$delayedJobs',
        const Color(0xFFDC2626),
        Icons.warning_amber_rounded,
        delayedJobs > 0 ? 'Alert' : null,
      ),
      (
        'Active techs',
        '${technicians.length}',
        const Color(0xFF7C3AED),
        Icons.engineering_rounded,
        null,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Operations Center Hero Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF07182E), Color(0xFF0F2B4C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF07182E).withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE OPERATIONS',
                    style: TextStyle(
                      color: gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Operations Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${jobs.length} total jobs  •  ${attention.length} need review  •  ${technicians.length} techs active',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        if (loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Live data warning: $loadError',
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),

        const SizedBox(height: 18),

        // Metrics Grid (2 columns on mobile, 4 columns on desktop)
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final columns = isMobile ? 2 : constraints.maxWidth >= 980 ? 4 : 3;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isMobile ? 1.35 : 1.7,
              children: metrics.map((item) {
                return SupervisorMetricCard(
                  label: item.$1,
                  value: item.$2,
                  color: item.$3,
                  icon: item.$4,
                  subtitle: item.$5,
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 20),

        // Jobs Requiring Attention
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEA580C),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Requires Immediate Attention',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (attention.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${attention.length}',
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (attention.isEmpty)
                const SupervisorEmpty(
                  message: 'No delayed or unverified jobs right now.',
                )
              else
                ...attention.take(5).map(
                  (job) => SupervisorJobCard(
                    job: job,
                    onTap: () => onOpenJob(job),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Job Status Pipeline
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Job Status Pipeline',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              ...JobProgress.stages.map((stage) {
                final count =
                    jobs.where((job) => job.progressStage == stage).length;
                final total = jobs.isEmpty ? 1 : jobs.length;
                final pct = (count / total).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            JobProgress.labelFor(stage),
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$count (${(pct * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 7,
                          color: navy,
                          backgroundColor: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Recent Activity
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              if (jobs.isEmpty)
                const SupervisorEmpty(
                  message: 'No jobs have been submitted yet.',
                )
              else
                ...jobs.take(6).map(
                  (job) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        serviceIcon(job.serviceName),
                        color: navy,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      '${job.customerName} • ${job.serviceName}',
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${JobProgress.labelFor(job.progressStage)} • ${job.preferredDate}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    onTap: () => onOpenJob(job),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
