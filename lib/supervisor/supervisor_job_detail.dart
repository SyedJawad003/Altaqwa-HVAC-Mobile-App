import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customer/services/booking_service.dart';
import '../customer/services/job_ops.dart';
import '../customer/theme/app_theme.dart';
import 'supervisor_widgets.dart';

class SupervisorJobDetailPage extends StatelessWidget {
  const SupervisorJobDetailPage({super.key, required this.jobId});
  final String jobId;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: supervisorTheme,
      child: StreamBuilder<List<BookingRequest>>(
        stream: BookingService().watchBookings(),
        builder: (context, snapshot) {
          final job = snapshot.data?.where((item) => item.id == jobId);
          final current = job == null || job.isEmpty ? null : job.first;
          return Scaffold(
            backgroundColor: const Color(0xFFF4F7FB),
            appBar: SupervisorAppBar(
              title: current != null ? current.serviceName : 'Job Details',
              subtitle: current != null ? current.customerName : 'Review & Verification',
              showMenu: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  tooltip: 'Back',
                ),
              ],
            ),
            body: current == null
                ? Center(
                    child: snapshot.hasError
                        ? Text('${snapshot.error}', style: const TextStyle(color: Colors.red))
                        : const CircularProgressIndicator(color: navy),
                  )
                : StreamBuilder<SiteDetails?>(
                    stream: BookingService().watchSiteDetailsForRequest(current.id),
                    builder: (ctx, siteSnap) {
                      final siteFromCollection = siteSnap.data;
                      final resolvedSite = siteFromCollection ??
                          current.siteDetails ??
                          ((current.photoUrls.isNotEmpty ||
                                  current.notes.isNotEmpty)
                              ? SiteDetails(
                                  description: current.notes,
                                  photoUrls: current.photoUrls,
                                  technicianName:
                                      '${current.customerName} (Customer Quote Request)',
                                  customerName: current.customerName,
                                  serviceName: current.serviceName,
                                  sharedAt: current.createdAt,
                                )
                              : null);
                      final merged =
                          current.copyWith(siteDetails: resolvedSite);
                      return _JobBody(job: merged);
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _JobBody extends StatelessWidget {
  const _JobBody({required this.job});
  final BookingRequest job;

  @override
  Widget build(BuildContext context) {
    final stageIndex = JobProgress.indexOf(job.progressStage);
    final sIcon = serviceIcon(job.serviceName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
      children: [
        // Main Overview Card
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(sIcon, color: navy, size: 24),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.customerName,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SupervisorStatusBadge(job: job),
                ],
              ),
              if (job.isQuoteRequest) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.request_quote_outlined, size: 16, color: Color(0xFF92400E)),
                      SizedBox(width: 6),
                      Text(
                        'Customer Quote Request',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    '${job.preferredDate} ${job.preferredTime}'.trim(),
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SupervisorPriorityBadge(priority: job.displayPriority),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Job Progress Tracker
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Job Progress Stages',
                style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < JobProgress.stages.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: i <= stageIndex ? navy : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        JobProgress.labelFor(JobProgress.stages[i]),
                        style: TextStyle(
                          color: i <= stageIndex ? Colors.white : const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (job.timeline.isEmpty)
                const Text(
                  'Timeline milestones will update as the technician progresses.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                )
              else ...[
                const Text(
                  'Activity Log',
                  style: TextStyle(color: navy, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ...job.timeline.reversed.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: gold, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['label'] as String? ??
                                    event['stage'] as String? ??
                                    'Update',
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              if ((event['note'] as String? ?? '').isNotEmpty)
                                Text(
                                  event['note'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
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
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Site Inspection & Analysis (from Technician)
        if (job.siteDetails != null) ...[
          SupervisorPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_rounded,
                        color: Color(0xFF15803D),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Site Analysis & Inspection',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Technician: ${job.siteDetails!.technicianName}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        '${job.siteDetails!.photoUrls.length} Photos',
                        style: const TextStyle(
                          color: Color(0xFF1D4ED8),
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
                _row(
                  Icons.person_outline_rounded,
                  'Customer',
                  job.siteDetails!.customerName.isNotEmpty
                      ? job.siteDetails!.customerName
                      : job.customerName,
                ),
                _row(
                  Icons.engineering_rounded,
                  'Technician',
                  job.siteDetails!.technicianName,
                ),
                if (job.siteDetails!.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      job.siteDetails!.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                if (job.siteDetails!.photoUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 72,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: job.siteDetails!.photoUrls.length,
                      itemBuilder: (context, idx) {
                        final photo = job.siteDetails!.photoUrls[idx];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _showFullImage(context, photo),
                            borderRadius: BorderRadius.circular(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AppSmartImage(
                                source: photo,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: () =>
                        _showSiteDetailsDialog(context, job.siteDetails!),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text(
                      'Open Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Customer Details
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer & Location',
                style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _row(Icons.person_outline_rounded, 'Customer', job.customerName),
              _row(Icons.phone_outlined, 'Phone', job.phone.isEmpty ? 'Not specified' : job.phone),
              _row(Icons.location_on_outlined, 'Location', job.address.isEmpty ? 'Not specified' : job.address),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Service & Technician
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Service Assignment',
                style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _row(Icons.handyman_outlined, 'Service', job.serviceName),
              _row(
                Icons.engineering_rounded,
                'Technician',
                job.technicianName?.isNotEmpty == true
                    ? job.technicianName!
                    : 'Unassigned',
              ),
              if (job.notes.isNotEmpty)
                _row(Icons.notes_rounded, 'Special Notes', job.notes),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Completion & Verification Data
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Technician Field Report',
                style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _row(
                Icons.description_outlined,
                'Tech Notes',
                job.technicianNotes.isEmpty ? 'None provided' : job.technicianNotes,
              ),
              _row(
                Icons.inventory_2_outlined,
                'Materials Used',
                job.materialsUsed.isEmpty ? 'None recorded' : job.materialsUsed,
              ),
              _row(
                Icons.rate_review_outlined,
                'Report Summary',
                job.completionReport.isEmpty ? 'Pending' : job.completionReport,
              ),
              if (job.customerFeedback.isNotEmpty)
                _row(
                  Icons.star_outline_rounded,
                  'Customer Feedback',
                  job.customerFeedback,
                ),
              if (job.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Field Photos',
                  style: TextStyle(color: navy, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                ...job.photoUrls.map(
                  (url) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      url,
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Cost Estimate Section (Supervisor)
        SupervisorPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: Color(0xFFB45309),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Cost Estimation',
                          style: TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Analyze site details and estimate the total project cost',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (job.costEstimate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Text(
                        _formatPrice(job.costEstimate!.totalAmount),
                        style: const TextStyle(
                          color: Color(0xFF065F46),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              if (job.costEstimate != null) ...[
                _buildEstimateSummary(context, job.costEstimate!),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openCostEstimator(context, job),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text(
                      'Edit Estimate',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: () => _openCostEstimator(context, job),
                    icon: const Icon(Icons.request_quote_rounded, size: 20),
                    label: const Text(
                      'Prepare Cost Estimate',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB45309),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Action Buttons for Verification
        if (job.needsVerification || job.isClosed) ...[
          const Text(
            'Supervisor Verification Actions',
            style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: () => _action(context, 'verify', 'Verify Completion'),
              icon: const Icon(Icons.verified_rounded, size: 20),
              label: const Text(
                'Verify & Approve Completion',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _action(context, 'rework', 'Request Rework'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Request Rework'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _action(context, 'revisit', 'Request Revisit'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Request Revisit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _action(context, 'escalate', 'Escalate to Admin'),
              icon: const Icon(Icons.arrow_upward_rounded, size: 16),
              label: const Text('Escalate to Admin'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _action(BuildContext context, String action, String title) async {
    final notes = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, color: navy),
        ),
        content: TextField(
          controller: notes,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Reason / Supervisory Note',
            hintText: 'Add an operational comment or instruction',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await BookingService().supervisorReviewJob(
        requestId: job.id,
        action: action,
        notes: notes.text,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title recorded successfully.'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSiteDetailsDialog(BuildContext context, SiteDetails details) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF0F766E),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Site Inspection Details',
                          style: TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Field assessment report & photographs',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Technician and Customer summary cards
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.engineering_rounded, size: 16, color: Color(0xFF0F766E)),
                                const SizedBox(width: 8),
                                const Text(
                                  'Technician:',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    details.technicianName.isNotEmpty
                                        ? details.technicianName
                                        : (job.technicianName ?? 'Technician'),
                                    style: const TextStyle(
                                      color: navy,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16, color: Color(0xFFE2E8F0)),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                                const SizedBox(width: 8),
                                const Text(
                                  'Customer:',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    details.customerName.isNotEmpty
                                        ? details.customerName
                                        : job.customerName,
                                    style: const TextStyle(
                                      color: navy,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (details.sharedAt != null) ...[
                              const Divider(height: 16, color: Color(0xFFE2E8F0)),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Shared At:',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${details.sharedAt!.day}/${details.sharedAt!.month}/${details.sharedAt!.year} at ${_formatTime(details.sharedAt!)}',
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description / Analysis
                      const Text(
                        'Site Analysis & Notes',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          details.description.isNotEmpty
                              ? details.description
                              : 'No written description provided.',
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Photos
                      Row(
                        children: [
                          const Text(
                            'Site Photographs',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${details.photoUrls.length}',
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (details.photoUrls.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Center(
                            child: Text(
                              'No photos attached for this site visit.',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: details.photoUrls.length,
                          itemBuilder: (context, index) {
                            final photo = details.photoUrls[index];
                            return GestureDetector(
                              onTap: () => _showFullImage(context, photo),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    AppSmartImage(
                                      source: photo,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String source) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: AppSmartImage(
                  source: source,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(ctx).padding.top + 10,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
  }

  String _formatPrice(num amount) {
    final a = amount.toDouble();
    final whole = a.truncate();
    final dec = ((a - whole) * 100).round().toString().padLeft(2, '0');
    return '\$${whole.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m.group(1)},')}.$dec';
  }

  Widget _buildEstimateSummary(BuildContext context, CostEstimate estimate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(
          Icons.person_outline_rounded,
          'Prepared by',
          estimate.supervisorName,
        ),
        if (estimate.estimatedAt != null)
          _row(
            Icons.access_time_rounded,
            'Estimated on',
            '${estimate.estimatedAt!.day}/${estimate.estimatedAt!.month}/${estimate.estimatedAt!.year}',
          ),
        if (estimate.notes.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              estimate.notes,
              style: const TextStyle(
                color: Color(0xFF78350F),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
        if (estimate.breakdown.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Breakdown',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Item',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: Text(
                          'Qty',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 82,
                        child: Text(
                          'Amount',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                ...estimate.breakdown.map(
                  (item) {
                    final label = (item['label'] as String?) ?? 'Item';
                    final qty = (item['quantity'] as num?)?.toDouble() ?? 1;
                    final price = (item['unitPrice'] as num?)?.toDouble() ??
                        (item['amount'] as num?)?.toDouble() ??
                        0;
                    final amt = (item['amount'] as num?)?.toDouble() ??
                        (qty * price);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2)}',
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 82,
                            child: Text(
                              _formatPrice(amt),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Total Estimate',
                          style: TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 60,
                        child: SizedBox.shrink(),
                      ),
                      SizedBox(
                        width: 82,
                        child: Text(
                          _formatPrice(estimate.totalAmount),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openCostEstimator(BuildContext context, BookingRequest job) async {
    final existing = job.costEstimate;
    final items = List<Map<String, dynamic>>.from(
      existing?.breakdown ??
          [
            {'label': 'Labor / Service Call', 'quantity': 1, 'unitPrice': 150.00},
            {'label': 'Diagnostic / Site Inspection', 'quantity': 1, 'unitPrice': 80.00},
          ],
    );
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    final totalNotifier = ValueNotifier<double>(existing?.totalAmount ?? 0);
    void recalc() {
      double t = 0;
      for (final it in items) {
        final qty = (it['quantity'] as num?)?.toDouble() ?? 1;
        final price = (it['unitPrice'] as num?)?.toDouble() ??
            (it['amount'] as num?)?.toDouble() ??
            0;
        t += qty * price;
      }
      totalNotifier.value = t;
    }

    recalc();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Dialog(
          insetPadding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: 560,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calculate_rounded,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cost Estimator',
                              style: TextStyle(
                                color: navy,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Prepare a cost estimate for admin approval',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 15,
                                  color: Color(0xFF0F172A),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Customer: ${job.customerName}  •  Service: ${job.serviceName}',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Line Items',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            final labelCtrl = TextEditingController(
                              text: (item['label'] as String?) ?? '',
                            );
                            final qtyCtrl = TextEditingController(
                              text: ((item['quantity'] as num?)?.toDouble() ?? 1)
                                  .toString(),
                            );
                            final priceCtrl = TextEditingController(
                              text: ((item['unitPrice'] as num?)?.toDouble() ??
                                      (item['amount'] as num?)?.toDouble() ??
                                      0)
                                  .toStringAsFixed(2),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: TextField(
                                      controller: labelCtrl,
                                      onChanged: (v) {
                                        items[idx]['label'] = v.trim();
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Item / service',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 72,
                                    child: TextField(
                                      controller: qtyCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      onChanged: (v) {
                                        final n = num.tryParse(v) ?? 0;
                                        items[idx]['quantity'] = n.toDouble();
                                        recalc();
                                        setSt(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Qty',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 96,
                                    child: TextField(
                                      controller: priceCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      onChanged: (v) {
                                        final n = num.tryParse(v) ?? 0;
                                        items[idx]['unitPrice'] = n.toDouble();
                                        recalc();
                                        setSt(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Unit \$',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 40,
                                    child: TextButton(
                                      onPressed: () {
                                        if (items.length > 1) {
                                          items.removeAt(idx);
                                          recalc();
                                          setSt(() {});
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                items.add({
                                  'label': '',
                                  'quantity': 1,
                                  'unitPrice': 0.0,
                                });
                                setSt(() {});
                              },
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text(
                                'Add Line Item',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: notesCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Supervisor notes (optional)',
                              hintText:
                                  'e.g. Recommend replacing compressor unit. Includes standard warranty labor.',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ValueListenableBuilder<double>(
                            valueListenable: totalNotifier,
                            builder: (_, total, __) => Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF3B0),
                                    Color(0xFFFFE082),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF0C419),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'TOTAL ESTIMATE',
                                    style: TextStyle(
                                      color: navy,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatPrice(total),
                                    style: const TextStyle(
                                      color: Color(0xFFB45309),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () async {
                            final cleaned = items
                                .where((it) =>
                                    ((it['label'] as String?) ?? '')
                                        .trim()
                                        .isNotEmpty)
                                .toList();
                            if (cleaned.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Add at least one line item with a label.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            double t = 0;
                            for (final it in cleaned) {
                              final qty =
                                  (it['quantity'] as num?)?.toDouble() ?? 1;
                              final price =
                                  (it['unitPrice'] as num?)?.toDouble() ?? 0;
                              it['amount'] = qty * price;
                              t += qty * price;
                            }
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              await BookingService().submitCostEstimate(
                                requestId: job.id,
                                totalAmount: t,
                                breakdown: cleaned,
                                supervisorName:
                                    user?.displayName ?? 'Supervisor',
                                supervisorUid: user?.uid,
                                notes: notesCtrl.text,
                              );
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Cost estimate submitted to admin!',
                                    ),
                                    backgroundColor: Color(0xFF16A34A),
                                  ),
                                );
                                Navigator.pop(ctx, true);
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Could not submit estimate: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text(
                            'Send to Admin',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB45309),
                            minimumSize: const Size.fromHeight(44),
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
          ),
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estimate saved. Admin has been notified.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }
}
