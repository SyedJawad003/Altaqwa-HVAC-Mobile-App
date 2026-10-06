import 'package:flutter/material.dart';

import '../customer/services/booking_service.dart';
import '../customer/theme/app_theme.dart';
import '../supervisor/supervisor_widgets.dart';

class AdminQuoteRequestsScreen extends StatefulWidget {
  const AdminQuoteRequestsScreen({super.key, this.bookingService});

  final BookingService? bookingService;

  @override
  State<AdminQuoteRequestsScreen> createState() =>
      _AdminQuoteRequestsScreenState();
}

class _AdminQuoteRequestsScreenState extends State<AdminQuoteRequestsScreen> {
  String _filter = 'All';

  BookingService get _service => widget.bookingService ?? BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Customer Quote Requests',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: StreamBuilder<List<CustomerQuoteRequest>>(
        stream: _service.watchCustomerQuoteRequests(),
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
            padding: const EdgeInsets.all(16),
            children: [
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
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (active.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.inbox_outlined,
                        size: 50,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No quote requests found.',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...active.map(
                  (request) => _QuoteRequestCard(
                    request: request,
                    onUpdateStatus: (status) =>
                        _service.updateCustomerQuoteRequestStatus(
                      request.id,
                      status,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
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

class _QuoteRequestCard extends StatelessWidget {
  const _QuoteRequestCard({
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
                    color: const Color(0xFFEFF6FF),
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
            // Contact Row
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
            // Description
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
            // Photos
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
            // Action Buttons
            if (request.isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onUpdateStatus('reviewed'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: navy,
                        side: const BorderSide(color: navy),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: const Text('Mark Reviewed'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => onUpdateStatus('quoted'),
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: const Text('Quotation Sent'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => onUpdateStatus('pending'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Reopen / Revert to Pending'),
                ),
              ),
            ],
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
    return '$dd/${d.year == DateTime.now().year ? mm : '$mm/${d.year}'} $hh:$min';
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
