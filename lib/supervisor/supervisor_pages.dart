import 'package:flutter/material.dart';

import '../customer/services/booking_service.dart';
import '../customer/services/job_ops.dart';
import '../customer/theme/app_theme.dart';
import 'supervisor_widgets.dart';

// ============================================================================
// 1. SUPERVISOR JOBS PAGE
// ============================================================================
class SupervisorJobsPage extends StatefulWidget {
  const SupervisorJobsPage({
    super.key,
    required this.jobs,
    required this.onOpenJob,
    this.loadError,
  });

  final List<BookingRequest> jobs;
  final ValueChanged<BookingRequest> onOpenJob;
  final Object? loadError;

  @override
  State<SupervisorJobsPage> createState() => _SupervisorJobsPageState();
}

class _SupervisorJobsPageState extends State<SupervisorJobsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.jobs.where((job) {
      final haystack =
          '${job.customerName} ${job.serviceName} ${job.address} ${job.technicianName ?? ''} ${job.status}'
              .toLowerCase();
      if (_query.isNotEmpty && !haystack.contains(_query.toLowerCase())) {
        return false;
      }
      switch (_filter) {
        case 'Assigned':
          return (job.technicianUid ?? '').isNotEmpty && !job.isClosed;
        case 'In progress':
          return job.isInProgress;
        case 'Needs review':
          return job.needsVerification;
        case 'Delayed':
          return job.isDelayed;
        case 'Verified':
          return job.isVerified;
        default:
          return true;
      }
    }).toList();

    final counts = {
      'All': widget.jobs.length,
      'Assigned': widget.jobs
          .where((j) => (j.technicianUid ?? '').isNotEmpty && !j.isClosed)
          .length,
      'In progress': widget.jobs.where((j) => j.isInProgress).length,
      'Needs review': widget.jobs.where((j) => j.needsVerification).length,
      'Delayed': widget.jobs.where((j) => j.isDelayed).length,
      'Verified': widget.jobs.where((j) => j.isVerified).length,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const SupervisorPageHeader(
          title: 'Assigned Jobs',
          subtitle:
              'Search, filter, and inspect field assignments and their real-time progress.',
        ),
        if (widget.loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${widget.loadError}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 14),

        // Search Bar with clear button
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search customer, service, tech, or address...',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, color: navy),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Scrollable Horizontal Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'All',
              'Assigned',
              'In progress',
              'Needs review',
              'Delayed',
              'Verified',
            ].map((filter) {
              final selected = _filter == filter;
              final count = counts[filter] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    '$filter ($count)',
                    style: TextStyle(
                      color: selected ? Colors.white : navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  selected: selected,
                  selectedColor: navy,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected ? navy : const Color(0xFFE2E8F0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _filter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        if (filtered.isEmpty)
          const SupervisorPanel(
            child: SupervisorEmpty(message: 'No jobs match your search/filter.'),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 820) {
                return Column(
                  children: filtered
                      .map(
                        (job) => SupervisorJobCard(
                          job: job,
                          onTap: () => widget.onOpenJob(job),
                        ),
                      )
                      .toList(),
                );
              }
              return SupervisorPanel(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingTextStyle: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w800,
                    ),
                    dataTextStyle: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w600,
                    ),
                    columns: const [
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Service')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Technician')),
                      DataColumn(label: Text('Appointment')),
                      DataColumn(label: Text('Priority')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('')),
                    ],
                    rows: filtered.map((job) {
                      return DataRow(
                        cells: [
                          DataCell(Text(job.customerName)),
                          DataCell(Text(job.serviceName)),
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Text(
                                job.address.isEmpty
                                    ? 'Not provided'
                                    : job.address,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              job.technicianName?.isNotEmpty == true
                                  ? job.technicianName!
                                  : 'Unassigned',
                            ),
                          ),
                          DataCell(
                            Text(
                              '${job.preferredDate} ${job.preferredTime}'.trim(),
                            ),
                          ),
                          DataCell(
                            SupervisorPriorityBadge(
                              priority: job.displayPriority,
                            ),
                          ),
                          DataCell(SupervisorStatusBadge(job: job)),
                          DataCell(
                            TextButton(
                              onPressed: () => widget.onOpenJob(job),
                              child: const Text('Details'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ============================================================================
// 2. SUPERVISOR MONITORING PAGE
// ============================================================================
class SupervisorMonitoringPage extends StatefulWidget {
  const SupervisorMonitoringPage({
    super.key,
    required this.jobs,
    required this.onOpenJob,
    this.loadError,
  });

  final List<BookingRequest> jobs;
  final ValueChanged<BookingRequest> onOpenJob;
  final Object? loadError;

  @override
  State<SupervisorMonitoringPage> createState() =>
      _SupervisorMonitoringPageState();
}

class _SupervisorMonitoringPageState extends State<SupervisorMonitoringPage> {
  String _activeQueue = 'All';

  @override
  Widget build(BuildContext context) {
    final delayed = widget.jobs.where((job) => job.isDelayed).toList();
    final pendingAction =
        widget.jobs.where((job) => job.isPendingAction).toList();
    final inProgress = widget.jobs.where((job) => job.isInProgress).toList();
    final needsVerification =
        widget.jobs.where((job) => job.needsVerification).toList();

    final queues = <String, List<BookingRequest>>{
      'Delayed': delayed,
      'Waiting Action': pendingAction,
      'In Progress': inProgress,
      'Review Needed': needsVerification,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const SupervisorPageHeader(
          title: 'Field Monitoring',
          subtitle:
              'Spot delayed work, idle assignments, live jobs, and completions awaiting your sign-off.',
        ),
        if (widget.loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${widget.loadError}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 14),

        // Queue filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', widget.jobs.length),
              _filterChip('Delayed', delayed.length, alert: delayed.isNotEmpty),
              _filterChip('Waiting Action', pendingAction.length),
              _filterChip('In Progress', inProgress.length),
              _filterChip(
                'Review Needed',
                needsVerification.length,
                alert: needsVerification.isNotEmpty,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // If 'All' is selected, show all sections, otherwise show active queue
        if (_activeQueue == 'All') ...[
          for (final entry in queues.entries)
            _buildQueueSection(entry.key, entry.value),
        ] else ...[
          _buildQueueSection(
            _activeQueue,
            queues[_activeQueue] ?? const <BookingRequest>[],
          ),
        ],
      ],
    );
  }

  Widget _filterChip(String label, int count, {bool alert = false}) {
    final selected = _activeQueue == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alert) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              '$label ($count)',
              style: TextStyle(
                color: selected ? Colors.white : navy,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        selected: selected,
        selectedColor: navy,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? navy
              : alert
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
        onSelected: (_) => setState(() => _activeQueue = label),
      ),
    );
  }

  Widget _buildQueueSection(String title, List<BookingRequest> items) {
    final isDelayedSection = title.toLowerCase().contains('delayed');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SupervisorPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDelayedSection
                      ? Icons.warning_amber_rounded
                      : Icons.view_list_rounded,
                  color: isDelayedSection ? const Color(0xFFDC2626) : navy,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$title (${items.length})',
                  style: TextStyle(
                    color: isDelayedSection ? const Color(0xFFDC2626) : navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const SupervisorEmpty(message: 'Queue is clear.')
            else
              ...items.map(
                (job) => SupervisorJobCard(
                  job: job,
                  onTap: () => widget.onOpenJob(job),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. SUPERVISOR TECHNICIANS PAGE
// ============================================================================
class SupervisorTechniciansPage extends StatelessWidget {
  const SupervisorTechniciansPage({
    super.key,
    required this.jobs,
    required this.technicians,
    this.loadError,
  });

  final List<BookingRequest> jobs;
  final List<TechnicianProfile> technicians;
  final Object? loadError;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const SupervisorPageHeader(
          title: 'Field Technicians',
          subtitle:
              'Monitor availability, active work status, assigned load, and completed tasks.',
        ),
        if (loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$loadError',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        if (technicians.isEmpty)
          const SupervisorPanel(
            child: SupervisorEmpty(message: 'No registered technicians found.'),
          )
        else
          ...technicians.map((technician) {
            final assigned = jobs
                .where((job) => job.technicianUid == technician.uid)
                .toList();
            final pending = assigned
                .where((job) => !job.isClosed && !job.isVerified)
                .length;
            final completed = assigned
                .where((job) => job.isClosed || job.isVerified)
                .length;
            final inProgress =
                assigned.where((job) => job.isInProgress).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F2744).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Avatar, Name, Phone, Status chip
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: navy.withValues(alpha: 0.1),
                          child: Text(
                            technician.name.isNotEmpty
                                ? technician.name[0].toUpperCase()
                                : 'T',
                            style: const TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                technician.name,
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    technician.phone.isNotEmpty
                                        ? technician.phone
                                        : technician.email,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: technician.available
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: technician.available
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFFCA5A5),
                            ),
                          ),
                          child: Text(
                            technician.available ? 'Available' : 'Busy',
                            style: TextStyle(
                              color: technician.available
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB42318),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),

                    // Workload Statistics Row (Assigned, Pending, Completed)
                    Row(
                      children: [
                        _techStatBox(
                          'Assigned',
                          '${assigned.length}',
                          const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 8),
                        _techStatBox(
                          'Active',
                          '$pending',
                          const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        _techStatBox(
                          'Done',
                          '$completed',
                          const Color(0xFF16A34A),
                        ),
                      ],
                    ),

                    if (inProgress.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              size: 16,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Now: ${inProgress.first.serviceName} (${inProgress.first.customerName})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF1E40AF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _techStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. SUPERVISOR ISSUES PAGE
// ============================================================================
class SupervisorIssuesPage extends StatefulWidget {
  const SupervisorIssuesPage({super.key, required this.jobs});
  final List<BookingRequest> jobs;

  @override
  State<SupervisorIssuesPage> createState() => _SupervisorIssuesPageState();
}

class _SupervisorIssuesPageState extends State<SupervisorIssuesPage> {
  final _service = BookingService();
  String _filter = 'All';

  Future<void> _createIssue() async {
    final type = ValueNotifier('delayed_job');
    final title = TextEditingController();
    final description = TextEditingController();
    BookingRequest? selected = widget.jobs.isEmpty ? null : widget.jobs.first;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Log Field Issue',
          style: TextStyle(fontWeight: FontWeight.w800, color: navy),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'delayed_job',
                      child: Text('Delayed job'),
                    ),
                    DropdownMenuItem(
                      value: 'customer_complaint',
                      child: Text('Customer complaint'),
                    ),
                    DropdownMenuItem(
                      value: 'technician_problem',
                      child: Text('Technician issue'),
                    ),
                    DropdownMenuItem(
                      value: 'parts',
                      child: Text('Parts / material missing'),
                    ),
                    DropdownMenuItem(
                      value: 'revisit',
                      child: Text('Revisit request'),
                    ),
                  ],
                  onChanged: (value) => type.value = value ?? 'delayed_job',
                  decoration: const InputDecoration(labelText: 'Issue type'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<BookingRequest>(
                  initialValue: selected,
                  items: widget.jobs
                      .map(
                        (job) => DropdownMenuItem(
                          value: job,
                          child: Text(
                            '${job.customerName} • ${job.serviceName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selected = value,
                  decoration: const InputDecoration(labelText: 'Related job'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Issue title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Details / observation',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Submit Issue'),
          ),
        ],
      ),
    );

    if (created != true || selected == null || title.text.trim().isEmpty) return;
    await _service.createJobIssue(
      requestId: selected!.id,
      type: type.value,
      title: title.text,
      description: description.text,
      customerName: selected!.customerName,
      technicianName: selected!.technicianName ?? '',
      serviceName: selected!.serviceName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JobIssue>>(
      stream: _service.watchJobIssues(),
      builder: (context, snapshot) {
        final allIssues = snapshot.data ?? const <JobIssue>[];
        final openCount = allIssues.where((i) => i.isOpen).length;
        final resolvedCount = allIssues.where((i) => !i.isOpen).length;

        final issues = allIssues.where((i) {
          if (_filter == 'Open') return i.isOpen;
          if (_filter == 'Resolved') return !i.isOpen;
          return true;
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SupervisorPageHeader(
              title: 'Operational Issues',
              subtitle:
                  'Logged issues are tracked and instantly synced to the Admin desk.',
              action: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: widget.jobs.isEmpty ? null : _createIssue,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    'Log New Issue',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Filter chips: All, Open, Resolved
            Row(
              children: [
                _chip('All', allIssues.length),
                const SizedBox(width: 8),
                _chip('Open', openCount, isAlert: openCount > 0),
                const SizedBox(width: 8),
                _chip('Resolved', resolvedCount),
              ],
            ),
            const SizedBox(height: 14),

            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (issues.isEmpty)
              const SupervisorPanel(
                child: SupervisorEmpty(message: 'No issues logged here.'),
              )
            else
              ...issues.map(
                (issue) => SupervisorIssueCard(
                  issue: issue,
                  onResolve: issue.isOpen
                      ? () => _service.resolveJobIssue(issue.id)
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _chip(String label, int count, {bool isAlert = false}) {
    final selected = _filter == label;
    return ChoiceChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: selected ? Colors.white : navy,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      selected: selected,
      selectedColor: isAlert ? const Color(0xFFDC2626) : navy,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected
            ? (isAlert ? const Color(0xFFDC2626) : navy)
            : const Color(0xFFE2E8F0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = label),
    );
  }
}

// ============================================================================
// 5. SUPERVISOR SCHEDULE PAGE
// ============================================================================
class SupervisorSchedulePage extends StatefulWidget {
  const SupervisorSchedulePage({
    super.key,
    required this.jobs,
    required this.onOpenJob,
  });

  final List<BookingRequest> jobs;
  final ValueChanged<BookingRequest> onOpenJob;

  @override
  State<SupervisorSchedulePage> createState() => _SupervisorSchedulePageState();
}

class _SupervisorSchedulePageState extends State<SupervisorSchedulePage> {
  int _selectedTab = 0; // 0: Today, 1: Upcoming

  @override
  Widget build(BuildContext context) {
    final today = widget.jobs.where((job) => job.isToday).toList();
    final upcoming = widget.jobs.where((job) => job.isUpcoming).toList();
    final activeList = _selectedTab == 0 ? today : upcoming;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const SupervisorPageHeader(
          title: 'Field Schedule',
          subtitle:
              "Real-time appointment schedule for today's visits and upcoming jobs.",
        ),
        const SizedBox(height: 14),

        // Segmented Tab Switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _tabButton(
                  'Today (${today.length})',
                  0,
                  Icons.today_rounded,
                ),
              ),
              Expanded(
                child: _tabButton(
                  'Upcoming (${upcoming.length})',
                  1,
                  Icons.calendar_month_rounded,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (activeList.isEmpty)
          SupervisorPanel(
            child: SupervisorEmpty(
              message: _selectedTab == 0
                  ? 'No visits scheduled for today.'
                  : 'No upcoming visits on the calendar.',
            ),
          )
        else
          ...activeList.map(
            (job) => SupervisorJobCard(
              job: job,
              onTap: () => widget.onOpenJob(job),
            ),
          ),
      ],
    );
  }

  Widget _tabButton(String text, int index, IconData icon) {
    final selected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? navy : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: selected ? navy : const Color(0xFF64748B),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. SUPERVISOR REPORTS PAGE (MOBILE-OPTIMIZED OVERHAUL)
// ============================================================================
class SupervisorReportsPage extends StatelessWidget {
  const SupervisorReportsPage({
    super.key,
    required this.jobs,
    required this.technicians,
  });

  final List<BookingRequest> jobs;
  final List<TechnicianProfile> technicians;

  @override
  Widget build(BuildContext context) {
    final total = jobs.length;
    final completed = jobs
        .where(
          (job) =>
              job.status.toLowerCase() == 'completed' || job.isVerified,
        )
        .length;
    final pending = jobs.where((job) => !job.isClosed && !job.isVerified).length;
    final delayed = jobs.where((job) => job.isDelayed).length;
    final revisits =
        jobs.where((job) => job.verificationStatus == 'revisit').length;

    final completionPct = total == 0 ? 0.0 : (completed / total);

    final services = <String, int>{};
    for (final job in jobs) {
      services[job.serviceName] = (services[job.serviceName] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const SupervisorPageHeader(
          title: 'Operational Reports',
          subtitle:
              'Completion rates, technician output, delayed work, and service demand breakdown.',
        ),
        const SizedBox(height: 16),

        // 2-Column Responsive KPI Grid (fits mobile screens perfectly)
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isMobile ? 1.35 : 1.7,
              children: [
                SupervisorMetricCard(
                  label: 'Completed ($completed / $total)',
                  value: '${(completionPct * 100).toStringAsFixed(0)}%',
                  color: const Color(0xFF16A34A),
                  icon: Icons.task_alt_rounded,
                  subtitle: 'Rate',
                ),
                SupervisorMetricCard(
                  label: 'Pending Jobs',
                  value: '$pending',
                  color: const Color(0xFFD97706),
                  icon: Icons.hourglass_top_rounded,
                  subtitle: 'Active',
                ),
                SupervisorMetricCard(
                  label: 'Delayed Jobs',
                  value: '$delayed',
                  color: const Color(0xFFDC2626),
                  icon: Icons.warning_amber_rounded,
                  subtitle: delayed > 0 ? 'Overdue' : 'Zero',
                ),
                SupervisorMetricCard(
                  label: 'Revisits Needed',
                  value: '$revisits',
                  color: const Color(0xFF7C3AED),
                  icon: Icons.replay_rounded,
                  subtitle: revisits > 0 ? 'Review' : 'Clear',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // Overall Completion Visual Progress Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2744).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Job Fulfillment',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(completionPct * 100).toStringAsFixed(0)}% Done',
                      style: const TextStyle(
                        color: Color(0xFF15803D),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionPct,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completed of $total total jobs completed',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$pending pending',
                    style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Technician Performance Section
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.engineering_rounded,
                    color: navy,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Technician Performance',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (technicians.isEmpty)
                const SupervisorEmpty(message: 'No technician data recorded yet.')
              else
                ...technicians.map((technician) {
                  final assigned = jobs.where(
                    (job) => job.technicianUid == technician.uid,
                  );
                  final done = assigned
                      .where(
                        (job) =>
                            job.isVerified ||
                            job.status.toLowerCase() == 'completed',
                      )
                      .length;
                  final assignedCount = assigned.length;
                  final techPct = assignedCount == 0 ? 0.0 : done / assignedCount;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: navy.withValues(alpha: 0.1),
                              child: Text(
                                technician.name.isNotEmpty
                                    ? technician.name[0].toUpperCase()
                                    : 'T',
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                technician.name,
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$done / $assignedCount Done',
                                style: const TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: techPct,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Service Volume Breakdown Section
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_rounded, color: navy, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Service Volume Breakdown',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (services.isEmpty)
                const SupervisorEmpty(message: 'No service volume logged yet.')
              else
                ...services.entries.map((entry) {
                  final servicePct = total == 0 ? 0.0 : entry.value / total;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              serviceIcon(entry.key),
                              size: 15,
                              color: navy,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.value} jobs (${(servicePct * 100).toStringAsFixed(0)}%)',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: servicePct,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: gold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 7. SUPERVISOR NOTIFICATIONS PAGE
// ============================================================================
class SupervisorNotificationsPage extends StatelessWidget {
  const SupervisorNotificationsPage({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: BookingService().watchSupervisorNotifications(uid),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Map<String, dynamic>>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const SupervisorPageHeader(
              title: 'Activity Notifications',
              subtitle:
                  'Real-time alerts for technician assignments, completions, delays, and issues.',
            ),
            const SizedBox(height: 14),
            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (items.isEmpty)
              const SupervisorPanel(
                child: SupervisorEmpty(message: 'No notifications at this time.'),
              )
            else
              ...items.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F2744).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: navy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String? ?? 'Notice',
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['message'] as String? ?? '',
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// 8. SUPERVISOR QUOTE REQUESTS PAGE
// ============================================================================
class SupervisorQuoteRequestsPage extends StatefulWidget {
  const SupervisorQuoteRequestsPage({
    super.key,
    required this.service,
  });

  final BookingService service;

  @override
  State<SupervisorQuoteRequestsPage> createState() =>
      _SupervisorQuoteRequestsPageState();
}

class _SupervisorQuoteRequestsPageState
    extends State<SupervisorQuoteRequestsPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CustomerQuoteRequest>>(
      stream: widget.service.watchCustomerQuoteRequests(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <CustomerQuoteRequest>[];
        final pending = all.where((r) => r.isPending).toList();
        final reviewed = all.where((r) => r.isReviewed).toList();
        final quoted = all.where((r) => r.isQuoted).toList();
        final active = switch (_filter) {
          'Pending' => pending,
          'Reviewed' => reviewed,
          'Quoted' => quoted,
          _ => all,
        };

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SupervisorPageHeader(
              title: 'Customer Quote Requests',
              subtitle:
                  'Customer-initiated quote requests. Review photos and requirements, then coordinate with Admin for quotations.',
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All', all.length),
                  const SizedBox(width: 8),
                  _chip('Pending', pending.length, alert: pending.isNotEmpty),
                  const SizedBox(width: 8),
                  _chip('Reviewed', reviewed.length),
                  const SizedBox(width: 8),
                  _chip('Quoted', quoted.length),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (active.isEmpty)
              const SupervisorPanel(
                child: SupervisorEmpty(
                  message: 'No customer quote requests yet.',
                ),
              )
            else
              ...active.map(
                (request) => _RequestCard(
                  request: request,
                  onUpdateStatus: (status) =>
                      widget.service.updateCustomerQuoteRequestStatus(
                    request.id,
                    status,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _chip(String label, int count, {bool alert = false}) {
    final selected = _filter == label;
    return ChoiceChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: selected ? Colors.white : navy,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      selected: selected,
      selectedColor: alert ? const Color(0xFFDC2626) : navy,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected
            ? (alert ? const Color(0xFFDC2626) : navy)
            : (alert ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = label),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onUpdateStatus,
  });

  final CustomerQuoteRequest request;
  final ValueChanged<String> onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2744).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    serviceIcon(request.serviceName),
                    color: navy,
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
                              request.serviceName,
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          _StatusBadge(status: request.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.customerName,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      if (request.createdAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(request.createdAt!),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                if (request.customerPhone.isNotEmpty)
                  _ContactChip(
                    icon: Icons.phone_outlined,
                    label: request.customerPhone,
                  ),
                if (request.customerEmail.isNotEmpty)
                  _ContactChip(
                    icon: Icons.email_outlined,
                    label: request.customerEmail,
                  ),
                if (request.address.isNotEmpty)
                  _ContactChip(
                    icon: Icons.location_on_outlined,
                    label: request.address,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (request.description.isNotEmpty) ...[
              const Text(
                'Requirements',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request.description,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (request.photoUrls.isNotEmpty) ...[
              const Text(
                'Site Photos',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: request.photoUrls
                    .map(
                      (url) => GestureDetector(
                        onTap: () => _showPhotoPreview(context, url),
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AppSmartImage(
                              source: url,
                              width: 74,
                              height: 74,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            if (request.isPending)
              FilledButton(
                onPressed: () => onUpdateStatus('reviewed'),
                style: FilledButton.styleFrom(
                  backgroundColor: navy,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Mark as Reviewed'),
              )
            else
              FilledButton(
                onPressed: () => onUpdateStatus('pending'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF475569),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Reopen / Revert to Pending'),
              ),
          ],
        ),
      ),
    );
  }

  void _showPhotoPreview(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppSmartImage(
                source: url,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} $hh:$min';
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF475569)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status.toLowerCase()) {
      'reviewed' => (
          const Color(0xFFDBEAFE),
          const Color(0xFF1D4ED8),
          'Reviewed'
        ),
      'quoted' => (
          const Color(0xFFDCFCE7),
          const Color(0xFF15803D),
          'Quoted'
        ),
      _ => (
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
          'Pending'
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
