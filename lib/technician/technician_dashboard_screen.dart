import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../customer/screens/login_screen.dart';
import '../customer/services/booking_service.dart';
import '../customer/services/job_ops.dart';
import '../customer/theme/app_theme.dart';
import 'share_site_details_screen.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});
  @override
  State<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  int _tab = 0;
  final _service = BookingService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in again.')),
      );
    }

    return Theme(
      data: _technicianTheme,
      child: StreamBuilder<TechnicianProfile?>(
        stream: _service.watchTechnicianProfile(user.uid),
        builder: (context, profileSnapshot) {
          final profile = profileSnapshot.data;
          return StreamBuilder<List<BookingRequest>>(
            stream: _service.watchTechnicianBookings(
              user.uid,
              technicianName: profile?.name,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Scaffold(
                  backgroundColor: Color(0xFFF4F7FB),
                  body: Center(child: CircularProgressIndicator(color: navy)),
                );
              }

              final jobs = snapshot.data ?? const <BookingRequest>[];
              final completed = jobs
                  .where((job) => job.status.toLowerCase() == 'completed')
                  .toList();
              final active = jobs
                  .where((job) => job.status.toLowerCase() != 'completed')
                  .toList();
              final pages = <Widget>[
                _DashboardTab(
                  technicianName: profile?.name ?? user.displayName ?? 'Technician',
                  active: active,
                  completed: completed,
                  loadError: snapshot.error,
                ),
                _JobsTab(
                  title: 'Assigned Jobs',
                  subtitle: 'Jobs the admin has assigned to you.',
                  jobs: active,
                  loadError: snapshot.error,
                ),
                _JobsTab(
                  title: 'Completed Jobs',
                  subtitle: 'Finished service visits.',
                  jobs: completed,
                  loadError: snapshot.error,
                ),
                _NotificationsTab(stream: _service.watchNotifications(user.uid)),
                _ProfileTab(user: user, profile: profile),
              ];
              return Scaffold(
                backgroundColor: const Color(0xFFF4F7FB),
                appBar: AppBar(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  title: const Text(
                    'Technician Panel',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                body: pages[_tab],
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _tab,
                  onDestinationSelected: (index) =>
                      setState(() => _tab = index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.assignment_outlined),
                      label: 'Assigned',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.check_circle_outline),
                      label: 'Completed',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_none),
                      label: 'Alerts',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      label: 'Profile',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

final ThemeData _technicianTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF4F7FB),
  colorScheme: const ColorScheme.light(
    primary: navy,
    onPrimary: Colors.white,
    secondary: gold,
    onSecondary: navy,
    surface: Colors.white,
    onSurface: navy,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: navy,
    indicatorColor: gold.withValues(alpha: 0.22),
    surfaceTintColor: navy,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return TextStyle(
        color: selected ? gold : Colors.white70,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 12,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return IconThemeData(color: selected ? gold : Colors.white);
    }),
  ),
);

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.technicianName,
    required this.active,
    required this.completed,
    this.loadError,
  });
  final String technicianName;
  final List<BookingRequest> active;
  final List<BookingRequest> completed;
  final Object? loadError;

  @override
  Widget build(BuildContext context) {
    final pending = active
        .where((job) => job.status.toLowerCase() != 'confirmed')
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        Text(
          'Hello, $technicianName',
          style: const TextStyle(
            color: navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Here is a live summary of the jobs assigned to you.',
          style: TextStyle(color: Color(0xFF667085), fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _CountCard(
                label: 'Assigned',
                value: active.length,
                color: const Color(0xFF1683EE),
                icon: Icons.assignment_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CountCard(
                label: 'Pending',
                value: pending,
                color: const Color(0xFFF59E0B),
                icon: Icons.schedule_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CountCard(
                label: 'Completed',
                value: completed.length,
                color: const Color(0xFF22A35A),
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ),
        if (loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Could not load jobs. $loadError',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          'Assigned jobs',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (active.isEmpty)
          const _EmptyState(
            text: 'No jobs assigned yet. New work will appear here.',
          ),
        ...active.map((job) => _JobCard(job: job)),
      ],
    );
  }
}

class _JobsTab extends StatelessWidget {
  const _JobsTab({
    required this.title,
    required this.subtitle,
    required this.jobs,
    this.loadError,
  });
  final String title;
  final String subtitle;
  final List<BookingRequest> jobs;
  final Object? loadError;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
    children: [
      Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(color: Color(0xFF667085))),
      if (loadError != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Could not load jobs. $loadError',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      const SizedBox(height: 16),
      if (jobs.isEmpty)
        const _EmptyState(text: 'No jobs in this section yet.'),
      ...jobs.map((job) => _JobCard(job: job)),
    ],
  );
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final BookingRequest job;

  @override
  Widget build(BuildContext context) {
    final dateTime = [
      if (job.preferredDate.isNotEmpty) job.preferredDate,
      if (job.preferredTime.isNotEmpty) job.preferredTime,
    ].join('  •  ');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E7EF)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TechnicianJobDetailsScreen(job: job),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.ac_unit, color: navy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.serviceName,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.customerName,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: job.status),
                ],
              ),
              const SizedBox(height: 14),
              _JobMeta(
                icon: Icons.event_outlined,
                text: dateTime.isEmpty ? 'Schedule not set' : dateTime,
              ),
              _JobMeta(
                icon: Icons.location_on_outlined,
                text: job.address.isEmpty ? 'Address not provided' : job.address,
              ),
              _JobMeta(
                icon: Icons.phone_outlined,
                text: job.phone.isEmpty ? 'Phone not provided' : job.phone,
              ),
              if (job.notes.isNotEmpty)
                _JobMeta(icon: Icons.notes_outlined, text: job.notes),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TechnicianJobDetailsScreen(job: job),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('View details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobMeta extends StatelessWidget {
  const _JobMeta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Assigned' : status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class TechnicianJobDetailsScreen extends StatefulWidget {
  const TechnicianJobDetailsScreen({super.key, required this.job});
  final BookingRequest job;

  @override
  State<TechnicianJobDetailsScreen> createState() =>
      _TechnicianJobDetailsScreenState();
}

class _TechnicianJobDetailsScreenState extends State<TechnicianJobDetailsScreen> {
  bool _saving = false;

  BookingRequest get job => widget.job;

  Future<void> _open(Uri uri, BuildContext context) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this action.')),
      );
    }
  }

  Future<void> _setStage(String stage) async {
    setState(() => _saving = true);
    try {
      await BookingService().updateJobProgress(requestId: job.id, stage: stage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${JobProgress.labelFor(stage)} saved.')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _technicianTheme,
      child: StreamBuilder<List<BookingRequest>>(
        stream: BookingService().watchBookings(),
        builder: (context, snapshot) {
          final matches =
              snapshot.data?.where((item) => item.id == widget.job.id);
          final current = matches != null && matches.isNotEmpty
              ? matches.first
              : widget.job;
          final completed =
              current.status.toLowerCase() == 'completed' || current.isVerified;

          return Scaffold(
            backgroundColor: const Color(0xFFF4F7FB),
            appBar: AppBar(
              backgroundColor: navy,
              foregroundColor: Colors.white,
              title: const Text('Job details'),
            ),
            body: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE1E7EF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.serviceName,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _Info(
                          'Status',
                          JobProgress.labelFor(current.progressStage),
                        ),
                        _Info('Customer', current.customerName),
                        _Info(
                          'Date and time',
                          '${current.preferredDate} at ${current.preferredTime}',
                        ),
                        _Info('Address', current.address),
                        _Info('Phone', current.phone),
                        _Info(
                          'Description',
                          current.notes.isEmpty
                              ? 'No description provided.'
                              : current.notes,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: current.phone.isEmpty
                                    ? null
                                    : () => _open(
                                        Uri.parse('tel:${current.phone}'),
                                        context,
                                      ),
                                icon: const Icon(Icons.call_outlined),
                                label: const Text('Call'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: current.address.isEmpty
                                    ? null
                                    : () => _open(
                                        Uri.parse(
                                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(current.address)}',
                                        ),
                                        context,
                                      ),
                                icon: const Icon(Icons.map_outlined),
                                label: const Text('Maps'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Share Site Details Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ShareSiteDetailsScreen(job: current),
                                ),
                              );
                            },
                            icon: Icon(
                              current.siteDetails != null
                                  ? Icons.check_circle_rounded
                                  : Icons.add_a_photo_outlined,
                              color: current.siteDetails != null
                                  ? const Color(0xFF15803D)
                                  : navy,
                              size: 18,
                            ),
                            label: Text(
                              current.siteDetails != null
                                  ? 'Site Details Shared (${current.siteDetails!.photoUrls.length} Photos) • Edit'
                                  : 'Share Site Details',
                              style: TextStyle(
                                color: current.siteDetails != null
                                    ? const Color(0xFF15803D)
                                    : navy,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: current.siteDetails != null
                                    ? const Color(0xFF86EFAC)
                                    : navy,
                                width: 1.5,
                              ),
                              backgroundColor: current.siteDetails != null
                                  ? const Color(0xFFF0FDF4)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        if (!completed) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Update progress',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              (JobProgress.accepted, 'Accepted'),
                              (JobProgress.onTheWay, 'On the way'),
                              (JobProgress.arrived, 'Arrived'),
                              (JobProgress.workStarted, 'Work started'),
                            ].map((item) {
                              return OutlinedButton(
                                onPressed: _saving
                                    ? null
                                    : () => _setStage(item.$1),
                                child: Text(item.$2),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: completed || _saving
                                ? null
                                : () => _complete(context),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              completed ? 'Job completed' : 'Complete job',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _complete(BuildContext context) async {
    final notes = TextEditingController();
    final materials = TextEditingController();
    final report = TextEditingController();
    final photos = TextEditingController();
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Complete job?'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add notes, materials, and optional photo links for supervisor review.'),
                  const SizedBox(height: 12),
                  TextField(controller: notes, decoration: const InputDecoration(labelText: 'Technician notes')),
                  const SizedBox(height: 8),
                  TextField(controller: materials, decoration: const InputDecoration(labelText: 'Materials used')),
                  const SizedBox(height: 8),
                  TextField(controller: report, maxLines: 3, decoration: const InputDecoration(labelText: 'Completion report')),
                  const SizedBox(height: 8),
                  TextField(controller: photos, decoration: const InputDecoration(labelText: 'Photo URLs (comma separated)')),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    setState(() => _saving = true);
    try {
      await BookingService().completeBooking(
        requestId: job.id,
        completedBy: FirebaseAuth.instance.currentUser?.uid,
        technicianNotes: notes.text,
        materialsUsed: materials.text,
        completionReport: report.text,
        photoUrls: photos.text
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
      );
      if (context.mounted) Navigator.pop(context);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab({required this.stream});
  final Stream<List<Map<String, dynamic>>> stream;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const <Map<String, dynamic>>[];
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: navy,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            if (notifications.isEmpty)
              const _EmptyState(text: 'No notifications yet.'),
            ...notifications.map(
              (item) => Card(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: gold,
                  ),
                  title: Text(
                    item['title'] as String? ?? 'Job update',
                    style: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    item['message'] as String? ?? '',
                    style: const TextStyle(color: Color(0xFF667085)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.user, this.profile});
  final User user;
  final TechnicianProfile? profile;

  Future<void> _logout(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log out?'),
            content: const Text('You will need to sign in again to see jobs.'),
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
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = profile?.name.isNotEmpty == true
        ? profile!.name
        : (user.displayName ?? 'Technician');
    final email = profile?.email.isNotEmpty == true
        ? profile!.email
        : (user.email ?? '');
    final phone = profile?.phone ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            color: navy,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [navyDeep, navy, Color(0xFF1E5A9C), gold],
              stops: [0, 0.42, 0.78, 1],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                child: Text(
                  name.isEmpty ? 'T' : name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Field technician',
                      style: TextStyle(color: Color(0xFFFFF3C4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined, color: navy),
                title: const Text(
                  'Email',
                  style: TextStyle(color: Color(0xFF667085), fontSize: 12),
                ),
                subtitle: Text(
                  email.isEmpty ? 'Not provided' : email,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phone_outlined, color: navy),
                title: const Text(
                  'Phone',
                  style: TextStyle(color: Color(0xFF667085), fontSize: 12),
                ),
                subtitle: Text(
                  phone.isEmpty ? 'Not provided' : phone,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () => _logout(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.22)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(color: navy, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 46),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.assignment_outlined, color: navy, size: 32),
        ),
        const SizedBox(height: 14),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
