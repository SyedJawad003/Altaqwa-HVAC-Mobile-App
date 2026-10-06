import 'package:flutter/material.dart';

import '../customer/services/booking_service.dart';
import '../customer/theme/app_theme.dart';
import '../supervisor/supervisor_widgets.dart';
import 'admin_navigation_drawer.dart';
import 'admin_quotation_screen.dart';
import 'admin_theme.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final BookingService _bookingService = BookingService();
  String _filter = 'All';

  bool _matchesFilter(BookingRequest request) {
    if (_filter == 'All') return true;
    if (_filter == 'Pending') {
      return request.status.toLowerCase() == 'pending' ||
          request.status.toLowerCase() == 'assigned';
    }
    return request.status.toLowerCase() == _filter.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AdminNavigationDrawer(),
      appBar: const AdminGradientAppBar(
        title: 'Requests',
        subtitle: 'Review and manage customer bookings.',
      ),
      body: StreamBuilder<List<BookingRequest>>(
        stream: _bookingService.watchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: navy));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load booking requests.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          final allRequests = snapshot.data ?? const <BookingRequest>[];
          final requests = allRequests.where(_matchesFilter).toList();
          final pending = allRequests.where((request) {
            final status = request.status.toLowerCase();
            return status == 'pending' || status == 'assigned';
          }).length;
          final confirmed = allRequests
              .where((request) => request.status.toLowerCase() == 'confirmed')
              .length;
          final completed = allRequests
              .where((request) => request.status.toLowerCase() == 'completed')
              .length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final pagePadding = constraints.maxWidth >= 900 ? 32.0 : 18.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pagePadding, 26, pagePadding, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service requests',
                                style: TextStyle(
                                  color: navy,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Review, assign, and track every customer request.',
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (constraints.maxWidth >= 600)
                          Text(
                            '${requests.length} shown',
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _RequestSummary(
                      total: allRequests.length,
                      pending: pending,
                      confirmed: confirmed,
                      completed: completed,
                    ),
                    const SizedBox(height: 26),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE1E7EF)),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 12,
                            spacing: 12,
                            children: [
                              const Text(
                                'Request list',
                                style: TextStyle(
                                  color: navy,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                children:
                                    [
                                      'All',
                                      'Pending',
                                      'Confirmed',
                                      'Completed',
                                    ].map((filter) {
                                      final selected = _filter == filter;
                                      return ChoiceChip(
                                        label: Text(
                                          filter,
                                          style: TextStyle(
                                            color: navy,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        selected: selected,
                                        onSelected: (_) =>
                                            setState(() => _filter = filter),
                                        selectedColor: gold,
                                        backgroundColor: const Color(
                                          0xFFF8FAFC,
                                        ),
                                        showCheckmark: false,
                                        side: BorderSide(
                                          color: selected
                                              ? gold
                                              : const Color(0xFFD7DEE8),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          requests.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 70,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _filter == 'All'
                                          ? 'No booking requests yet.'
                                          : 'No $_filter requests.',
                                      style: const TextStyle(
                                        color: navy,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                              : _RequestsTable(requests: requests),
                        ],
                      ),
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

class _RequestsTable extends StatelessWidget {
  const _RequestsTable({required this.requests});

  final List<BookingRequest> requests;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(
              navy.withValues(alpha: 0.08),
            ),
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
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Address')),
              DataColumn(label: Text('Technician')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Quotation')),
              DataColumn(label: Text('')),
            ],
            rows: requests.map((request) {
              final technician = request.technicianName?.trim();
              return DataRow(
                cells: [
                  DataCell(Text(request.customerName)),
                  DataCell(Text(request.serviceName)),
                  DataCell(
                    Text(
                      request.preferredDate.isEmpty
                          ? 'Not set'
                          : request.preferredDate,
                    ),
                  ),
                  DataCell(
                    Text(
                      request.preferredTime.isEmpty
                          ? 'Not set'
                          : request.preferredTime,
                    ),
                  ),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        request.address.isEmpty
                            ? 'Not provided'
                            : request.address,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      technician == null || technician.isEmpty
                          ? 'Unassigned'
                          : technician,
                    ),
                  ),
                  DataCell(_StatusBadge(status: request.status)),
                  DataCell(
                    request.quotation == null
                        ? const Text(
                            'Not created',
                            style: TextStyle(color: Color(0xFF98A2B3)),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (request.quotation!.status.toLowerCase() ==
                                  'sent')
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF16A34A),
                                    size: 18,
                                  ),
                                ),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => AdminRequestDetailsScreen(
                                      request: request,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'AED ${request.quotation!.totalAmount.toStringAsFixed(2)} • View',
                                ),
                              ),
                            ],
                          ),
                  ),
                  DataCell(
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              AdminRequestDetailsScreen(request: request),
                        ),
                      ),
                      child: const Text('View details'),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RequestSummary extends StatelessWidget {
  const _RequestSummary({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.completed,
  });

  final int total;
  final int pending;
  final int confirmed;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total requests', total, navy, Icons.inbox_outlined),
      (
        'Pending',
        pending,
        Colors.orange.shade700,
        Icons.pending_actions_outlined,
      ),
      ('Confirmed', confirmed, Colors.blue.shade700, Icons.verified_outlined),
      (
        'Completed',
        completed,
        Colors.green.shade700,
        Icons.check_circle_outline,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 4.8 : 2.5,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE1E7EF)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.$3.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.$4, color: item.$3),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${item.$2}',
                        style: const TextStyle(
                          color: navy,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase() == 'assigned' ? 'Pending' : status;
    final color = normalized.toLowerCase() == 'completed'
        ? Colors.green
        : normalized.toLowerCase() == 'confirmed'
        ? Colors.blue
        : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        normalized.toUpperCase(),
        style: TextStyle(
          color: color.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AdminRequestDetailsScreen extends StatefulWidget {
  const AdminRequestDetailsScreen({super.key, required this.request});

  final BookingRequest request;

  @override
  State<AdminRequestDetailsScreen> createState() =>
      _AdminRequestDetailsScreenState();
}

class _AdminRequestDetailsScreenState extends State<AdminRequestDetailsScreen> {
  late String _technicianUid = widget.request.technicianUid?.trim() ?? '';
  late Quotation? _quotation = widget.request.quotation;
  final BookingService _bookingService = BookingService();
  bool _saving = false;

  Future<void> _update(Future<void> Function() action, String message) async {
    setState(() => _saving = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.request.status.toLowerCase() == 'completed';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      drawer: const AdminNavigationDrawer(),
      appBar: const AdminGradientAppBar(
        title: 'Request details',
        subtitle: 'Assign and track this booking.',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.request.customerName,
                            style: const TextStyle(
                              color: navy,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _StatusBadge(status: widget.request.status),
                      ],
                    ),
                    if (widget.request.isQuoteRequest) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.request_quote_outlined,
                              size: 16,
                              color: Color(0xFF92400E),
                            ),
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
                    const SizedBox(height: 20),
                    _InfoRow(
                      label: 'Service',
                      value: widget.request.serviceName,
                    ),
                    _InfoRow(label: 'Phone', value: widget.request.phone),
                    if (widget.request.customerEmail.isNotEmpty)
                      _InfoRow(
                        label: 'Email',
                        value: widget.request.customerEmail,
                      ),
                    _InfoRow(label: 'Address', value: widget.request.address),
                    _InfoRow(
                      label: 'Date',
                      value: widget.request.preferredDate,
                    ),
                    _InfoRow(
                      label: 'Time',
                      value: widget.request.preferredTime,
                    ),
                    if (widget.request.notes.isNotEmpty)
                      _InfoRow(label: 'Notes', value: widget.request.notes),
                    const SizedBox(height: 20),
                    StreamBuilder<List<TechnicianProfile>>(
                      stream: _bookingService.watchTechnicians(),
                      builder: (context, technicianSnapshot) {
                        final technicians =
                            technicianSnapshot.data ??
                            const <TechnicianProfile>[];
                        var selectedUid = _technicianUid;
                        if (selectedUid.isEmpty) {
                          final existingName = widget.request.technicianName
                              ?.trim();
                          if (existingName != null && existingName.isNotEmpty) {
                            for (final technician in technicians) {
                              if (technician.name == existingName) {
                                selectedUid = technician.uid;
                                break;
                              }
                            }
                          }
                        }

                        if (technicianSnapshot.hasError) {
                          return Text(
                            'Could not load technicians: ${technicianSnapshot.error}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          initialValue:
                              technicians.any(
                                (technician) => technician.uid == selectedUid,
                              )
                              ? selectedUid
                              : null,
                          hint: const Text(
                            'Select technician',
                            style: TextStyle(color: Color(0xFF667085)),
                          ),
                          dropdownColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: 'Assign technician',
                            labelStyle: TextStyle(color: Color(0xFF667085)),
                            filled: true,
                            fillColor: Color(0xFFF8FAFC),
                          ),
                          style: const TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w700,
                          ),
                          items: technicians
                              .map(
                                (technician) => DropdownMenuItem(
                                  value: technician.uid,
                                  child: Text(
                                    technician.email.isEmpty
                                        ? technician.name
                                        : '${technician.name}  •  ${technician.email}',
                                    style: const TextStyle(color: navy),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isCompleted || _saving
                              ? null
                              : (value) => setState(
                                  () => _technicianUid = value ?? '',
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton(
                          onPressed:
                              isCompleted || _technicianUid.isEmpty || _saving
                              ? null
                              : () => _update(() async {
                                  final technicians = await _bookingService
                                      .watchTechnicians()
                                      .first;
                                  final technician = technicians.firstWhere(
                                    (item) => item.uid == _technicianUid,
                                    orElse: () => TechnicianProfile(
                                      uid: _technicianUid,
                                      name:
                                          widget.request.technicianName ??
                                          'Technician',
                                      email: '',
                                      phone: '',
                                    ),
                                  );
                                  await _bookingService.assignTechnician(
                                    requestId: widget.request.id,
                                    technicianName: technician.name,
                                    technicianUid: technician.uid,
                                  );
                                }, 'Technician assigned.'),
                          child: const Text('Assign technician'),
                        ),
                        OutlinedButton(
                          onPressed:
                              isCompleted || _technicianUid.isEmpty || _saving
                              ? null
                              : () => _update(() async {
                                  final technicians = await _bookingService
                                      .watchTechnicians()
                                      .first;
                                  final technician = technicians.firstWhere(
                                    (item) => item.uid == _technicianUid,
                                    orElse: () => TechnicianProfile(
                                      uid: _technicianUid,
                                      name:
                                          widget.request.technicianName ??
                                          'Technician',
                                      email: '',
                                      phone: '',
                                    ),
                                  );
                                  await _bookingService.confirmBooking(
                                    requestId: widget.request.id,
                                    technicianName: technician.name,
                                    technicianUid: technician.uid,
                                  );
                                }, 'Request confirmed.'),
                          child: const Text('Accept and confirm'),
                        ),
                        FilledButton(
                          onPressed:
                              !isCompleted &&
                                  widget.request.status.toLowerCase() ==
                                      'confirmed' &&
                                  _saving == false
                              ? () => _update(
                                  () => _bookingService.completeBooking(
                                    requestId: widget.request.id,
                                  ),
                                  'Request marked completed.',
                                )
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Mark completed'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    StreamBuilder<SiteDetails?>(
                      stream: BookingService().watchSiteDetailsForRequest(
                        widget.request.id,
                      ),
                      builder: (_, siteSnap) {
                        final resolved =
                            siteSnap.data ?? widget.request.siteDetails;
                        return _SiteDetailsCard(
                          request: widget.request,
                          overrideSiteDetails: resolved,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _CostEstimateCard(
                      estimate: widget.request.costEstimate,
                      customerName: widget.request.customerName,
                    ),
                    const SizedBox(height: 16),
                    _QuotationActionCard(
                      request: widget.request.copyWith(
                        quotation: _quotation,
                        clearQuotation: _quotation == null,
                      ),
                      onCreateQuotation: () async {
                        final result = await Navigator.of(context)
                            .push<Quotation>(
                              MaterialPageRoute(
                                builder: (_) => AdminQuotationScreen(
                                  request: widget.request.copyWith(
                                    quotation: _quotation,
                                    clearQuotation: _quotation == null,
                                  ),
                                ),
                              ),
                            );
                        if (result != null && context.mounted) {
                          setState(() => _quotation = result);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Quotation generated. Send it to the customer when ready.',
                              ),
                              backgroundColor: Color(0xFF16A34A),
                            ),
                          );
                        }
                      },
                      onSendQuotation: () async {
                        final quotation = _quotation;
                        if (quotation == null) return;
                        final result = await Navigator.of(context)
                            .push<Quotation>(
                              MaterialPageRoute(
                                builder: (_) => AdminQuotationScreen(
                                  request: widget.request.copyWith(
                                    quotation: quotation,
                                  ),
                                  sendOnly: true,
                                ),
                              ),
                            );
                        if (result != null && context.mounted) {
                          setState(() => _quotation = result);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Quotation sent to the customer.'),
                              backgroundColor: Color(0xFF16A34A),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatAmount(num amount) {
  final a = amount.toDouble();
  final whole = a.truncate();
  final dec = ((a - whole) * 100).round().toString().padLeft(2, '0');
  return 'AED ${whole.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m.group(1)},')}.$dec';
}

class _SiteDetailsCard extends StatelessWidget {
  const _SiteDetailsCard({required this.request, this.overrideSiteDetails});
  final BookingRequest request;
  final SiteDetails? overrideSiteDetails;

  @override
  Widget build(BuildContext context) {
    final sd =
        overrideSiteDetails ??
        request.siteDetails ??
        ((request.photoUrls.isNotEmpty || request.notes.isNotEmpty)
            ? SiteDetails(
                description: request.notes,
                photoUrls: request.photoUrls,
                technicianName:
                    '${request.customerName} (Customer Quote Request)',
                customerName: request.customerName,
                serviceName: request.serviceName,
                sharedAt: request.createdAt,
              )
            : null);
    if (sd == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.broken_image_outlined,
                color: Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Site Inspection Details',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'No site details submitted by technician yet.',
                    style: TextStyle(
                      color: Color(0xFF78350F),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final photos = List<String>.from(sd.photoUrls);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_city_rounded, color: navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Site Inspection Details',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (sd.technicianName.isNotEmpty)
                      Text(
                        'Submitted by ${sd.technicianName}',
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${photos.length} ${photos.length == 1 ? 'photo' : 'photos'}',
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (sd.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                sd.description,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, idx) {
                  final src = photos[idx];
                  return GestureDetector(
                    onTap: () => _openImage(context, src),
                    child: AspectRatio(
                      aspectRatio: 1.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppSmartImage(source: src, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: photos.length,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openImage(BuildContext context, String src) {
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
                maxScale: 4,
                child: AppSmartImage(source: src, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: MediaQuery.of(ctx).padding.top + 10,
              right: 14,
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
}

class _CostEstimateCard extends StatelessWidget {
  const _CostEstimateCard({required this.estimate, required this.customerName});
  final CostEstimate? estimate;
  final String customerName;

  @override
  Widget build(BuildContext context) {
    if (estimate == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calculate_rounded,
                color: Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supervisor Cost Estimate',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pending from supervisor for $customerName.',
                    style: const TextStyle(
                      color: Color(0xFF78350F),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final e = estimate!;
    final breakdown = e.breakdown;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF7C948)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supervisor Cost Estimate',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Prepared by ${e.supervisorName}',
                      style: const TextStyle(
                        color: Color(0xFF78350F),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatAmount(e.totalAmount),
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (e.notes.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6CC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                e.notes,
                style: const TextStyle(
                  color: Color(0xFF78350F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (breakdown.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1E5A8)),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Item',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            'Qty',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            'Amount',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1E5A8)),
                  ...breakdown.map((item) {
                    final label = (item['label'] as String?) ?? 'Item';
                    final qty = (item['quantity'] as num?)?.toDouble() ?? 1;
                    final up =
                        (item['unitPrice'] as num?)?.toDouble() ??
                        (item['amount'] as num?)?.toDouble() ??
                        0;
                    final amt =
                        (item['amount'] as num?)?.toDouble() ?? (qty * up);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: navy,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                            width: 90,
                            child: Text(
                              _formatAmount(amt),
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
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuotationActionCard extends StatelessWidget {
  const _QuotationActionCard({
    required this.request,
    required this.onCreateQuotation,
    required this.onSendQuotation,
  });
  final BookingRequest request;
  final VoidCallback onCreateQuotation;
  final VoidCallback onSendQuotation;

  @override
  Widget build(BuildContext context) {
    final q = request.quotation;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: goldLight.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: goldLight),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Quotation',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      q == null
                          ? 'Create an official quotation for ${request.customerName}.'
                          : '${q.quotationNumber} • ${q.status.toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (q != null)
                Text(
                  _formatAmount(q.totalAmount),
                  style: const TextStyle(
                    color: goldLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
            ],
          ),
          if (q != null) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFF475569)),
            for (final item in q.breakdown)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (item['label'] as String?)?.trim().isNotEmpty == true
                            ? (item['label'] as String).trim()
                            : 'Item',
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      _formatAmount(
                        (item['amount'] as num?)?.toDouble() ??
                            ((item['quantity'] as num?)?.toDouble() ?? 1) *
                                ((item['unitPrice'] as num?)?.toDouble() ?? 0),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            if (q.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                q.notes,
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
              ),
            ],
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCreateQuotation,
                  icon: Icon(
                    q == null ? Icons.add_rounded : Icons.edit_note_rounded,
                    size: 18,
                  ),
                  label: Text(
                    q == null ? 'Create Quotation' : 'Regenerate Quotation',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: goldLight,
                    foregroundColor: navy,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (q != null && q.status.toLowerCase() != 'sent') ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSendQuotation,
                    icon: const Icon(Icons.send_rounded, size: 17),
                    label: const Text(
                      'Send to Customer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: goldLight,
                      side: const BorderSide(color: goldLight),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF667085),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: navy, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
