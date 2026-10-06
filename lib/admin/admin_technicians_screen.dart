import 'package:flutter/material.dart';

import '../customer/services/booking_service.dart';
import '../customer/theme/app_theme.dart';
import 'admin_navigation_drawer.dart';
import 'admin_requests_screen.dart';
import 'admin_theme.dart';

class AdminTechniciansScreen extends StatelessWidget {
  AdminTechniciansScreen({super.key, BookingService? bookingService})
    : bookingService = bookingService ?? BookingService();

  final BookingService bookingService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AdminNavigationDrawer(),
      appBar: const AdminGradientAppBar(
        title: 'Technicians',
        subtitle: 'Registered technicians and workload overview.',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<List<TechnicianProfile>>(
              stream: bookingService.watchTechnicians(),
              builder: (context, snapshot) {
                final techs = snapshot.data ?? const <TechnicianProfile>[];
                final total = techs.length;
                final active = techs.where((t) => t.workStatus == 'active').length;
                final available = techs.where((t) => t.available).length;
                return Container(
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
                        'Technician Overview',
                        style: TextStyle(
                          color: navy,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _statChip(context, 'Total', total.toString(), navy),
                          _statChip(context, 'Active', active.toString(), const Color(0xFF16A34A)),
                          _statChip(context, 'Available', available.toString(), gold),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AdminRequestsScreen(),
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
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<List<TechnicianProfile>>(
                stream: bookingService.watchTechnicians(),
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
                          'Unable to load technicians.\n${snapshot.error}',
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

                  final technicians = snapshot.data ?? const <TechnicianProfile>[];

                  if (technicians.isEmpty) {
                    return const Center(
                      child: Text(
                        'No registered technicians yet.',
                        style: TextStyle(
                          color: navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: technicians.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tech = technicians[index];
                      return _TechnicianCard(
                        tech: tech,
                        bookingService: bookingService,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, String label, String value, Color color) {
    return Container(
      constraints: BoxConstraints(
        minWidth: (MediaQuery.sizeOf(context).width - 36 - 20) / 3,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicianCard extends StatefulWidget {
  const _TechnicianCard({
    required this.tech,
    required this.bookingService,
  });

  final TechnicianProfile tech;
  final BookingService bookingService;

  @override
  State<_TechnicianCard> createState() => _TechnicianCardState();
}

class _TechnicianCardState extends State<_TechnicianCard> {
  bool _loading = false;
  int? _jobCount;

  TechnicianProfile get tech => widget.tech;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final c = await widget.bookingService.countJobsForTechnician(
      uid: tech.uid,
      name: tech.name,
    );
    if (mounted) setState(() => _jobCount = c);
  }

  Future<void> _toggleAvailable() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.bookingService.toggleTechnicianAvailable(tech.uid, tech.available);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tech.available
                  ? '${tech.name} marked as on break.'
                  : '${tech.name} marked as available.',
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(tech.name);
    final isActive = tech.workStatus == 'active';
    final isAvailable = tech.available;
    final contactParts = <String>[
      if (tech.email.isNotEmpty) tech.email,
      if (tech.phone.isNotEmpty) tech.phone,
    ];
    final jobsCount = _jobCount;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2744).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: navy,
            foregroundColor: Colors.white,
            child: initials.isEmpty
                ? const Icon(Icons.person, size: 24)
                : Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tech.name,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                if (contactParts.isNotEmpty)
                  Text(
                    contactParts.join('  •  '),
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Badge(
                      label: isActive ? 'Active' : 'Inactive',
                      foreground: Colors.white,
                      background: isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                    ),
                    _Badge(
                      label: isAvailable ? 'Available' : 'On break',
                      foreground: isAvailable ? const Color(0xFF065F46) : const Color(0xFF78350F),
                      background: isAvailable
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFDE68A),
                    ),
                    _Badge(
                      label: jobsCount == null
                          ? 'Loading jobs…'
                          : '$jobsCount assigned',
                      foreground: navy,
                      background: const Color(0xFFDBEAFE),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Toggle availability',
            onPressed: _toggleAvailable,
            icon: Icon(
              isAvailable ? Icons.toggle_on : Icons.toggle_off,
              color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
              size: 34,
            ),
            isSelected: isAvailable,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first.toUpperCase()}${parts.last.characters.first.toUpperCase()}';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}
