import 'package:flutter/material.dart';

import '../customer/theme/app_theme.dart';
import '../customer/services/booking_service.dart';
import '../customer/services/job_ops.dart';
import '../supervisor/supervisor_widgets.dart';
import 'admin_navigation_drawer.dart';
import 'admin_theme.dart';

class AdminSupervisorIssuesScreen extends StatelessWidget {
  const AdminSupervisorIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminPageBg,
      drawer: const AdminNavigationDrawer(),
      appBar: const AdminGradientAppBar(
        title: 'Supervisors',
        subtitle: 'Issues logged by field supervisors.',
      ),
      body: StreamBuilder<List<JobIssue>>(
        stream: BookingService().watchJobIssues(),
        builder: (context, snapshot) {
          final issues = snapshot.data ?? const <JobIssue>[];
          final openCount = issues.where((issue) => issue.isOpen).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
            children: [
              const Text(
                'Supervisor reports',
                style: TextStyle(
                  color: navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Every issue a supervisor logs appears here in real time.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SupervisorMetricCard(
                      label: 'Total reports',
                      value: '${issues.length}',
                      color: navy,
                      icon: Icons.flag_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SupervisorMetricCard(
                      label: 'Open',
                      value: '$openCount',
                      color: const Color(0xFFB45309),
                      icon: Icons.error_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: navy),
                  ),
                ),
              if (snapshot.hasError)
                Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              if (issues.isEmpty && snapshot.hasData)
                const SupervisorPanel(
                  child: SupervisorEmpty(
                    message: 'No supervisor issues have been logged yet.',
                  ),
                ),
              ...issues.map(
                (issue) => SupervisorIssueCard(
                  issue: issue,
                  onResolve: issue.isOpen
                      ? () => BookingService().resolveJobIssue(issue.id)
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
