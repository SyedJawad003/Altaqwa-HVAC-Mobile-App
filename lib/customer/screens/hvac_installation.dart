import 'package:flutter/material.dart';

import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_page_route.dart';

class HvacInstallationScreen extends StatelessWidget {
  const HvacInstallationScreen({super.key});

  static const steps = [
    _StepData(
      'Site Inspection',
      'We assess your space.',
      Icons.search_outlined,
    ),
    _StepData(
      'System Selection',
      'We recommend the right system.',
      Icons.tune_outlined,
    ),
    _StepData(
      'Professional Installation',
      'Installed safely and efficiently.',
      Icons.build_outlined,
    ),
    _StepData(
      'Testing & Handover',
      'Tested and ready to use.',
      Icons.fact_check_outlined,
    ),
  ];

  static const benefits = [
    _BenefitData(
      'Professional Technicians',
      'Skilled experts handle every detail.',
      Icons.engineering_outlined,
    ),
    _BenefitData(
      'Quality Equipment',
      'Reliable systems built to perform.',
      Icons.verified_outlined,
    ),
    _BenefitData(
      'Proper Installation',
      'Careful setup for lasting comfort.',
      Icons.home_repair_service_outlined,
    ),
    _BenefitData(
      'After-Installation Support',
      'We remain available when you need us.',
      Icons.support_agent_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    body: SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/services.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: navy.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HVAC INSTALLATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _CircleButton(
                icon: Icons.arrow_back,
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _CircleButton(
                icon: Icons.notifications_none,
                tooltip: 'Notifications',
                iconColor: goldLight,
                onPressed: () =>
                    _showMessage(context, 'You are all caught up.'),
              ),
            ),
            Positioned.fill(
              child: DraggableScrollableSheet(
                initialChildSize: 0.61,
                minChildSize: 0.48,
                maxChildSize: 0.91,
                snap: true,
                snapSizes: const [0.61, 0.91],
                builder: (context, scrollController) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: _DetailsPanel(controller: scrollController),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  static void _showMessage(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white),
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: 0.2),
          blurRadius: 14,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Text(
            'Professional HVAC Installation',
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Complete HVAC installation for homes, offices and commercial spaces.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Color(0xFF5E6874), fontSize: 10.5),
          ),
          const SizedBox(height: 9),
          const _SectionTitle('Installation Process'),
          const SizedBox(height: 5),
          Column(
            children: HvacInstallationScreen.steps
                .asMap()
                .entries
                .map(
                  (entry) => _TimelineRow(
                    index: entry.key + 1,
                    data: entry.value,
                    isLast:
                        entry.key == HvacInstallationScreen.steps.length - 1,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 7),
          const _SectionTitle('Why Choose Us'),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: HvacInstallationScreen.benefits.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (_, index) =>
                _BenefitItem(data: HvacInstallationScreen.benefits[index]),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context)
                  .push(appPageRoute<void>(const AppointmentBookingScreen(
                    serviceName: 'HVAC Installation',
                  ))),
              icon: const Icon(Icons.calendar_month_outlined, size: 15),
              label: const Text('Schedule Installation'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(36),
                padding: EdgeInsets.zero,
                backgroundColor: gold,
                foregroundColor: navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, color: iconColor, size: 21),
    style: IconButton.styleFrom(
      backgroundColor: navy.withValues(alpha: 0.8),
      shape: const CircleBorder(),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      Container(
        width: 30,
        height: 2,
        decoration: BoxDecoration(
          color: gold,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ],
  );
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.index,
    required this.data,
    required this.isLast,
  });

  final int index;
  final _StepData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 43,
    child: Row(
      children: [
        SizedBox(
          width: 26,
          child: Column(
            children: [
              Container(
                width: 23,
                height: 23,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: navy,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: goldLight,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: gold.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E5EA)),
              boxShadow: [
                BoxShadow(
                  color: navy.withValues(alpha: 0.07),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.icon, color: navy, size: 14),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    data.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF5E6874),
                      fontSize: 8.5,
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
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.data});

  final _BenefitData data;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE0E5EA)),
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(data.icon, color: navy, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: navy,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5E6874),
                  fontSize: 7.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class AppointmentBookingScreen extends StatelessWidget {
  const AppointmentBookingScreen({super.key, required this.serviceName});

  final String serviceName;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/services.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: navy.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  serviceName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: _CircleButton(
              icon: Icons.arrow_back,
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize: 0.82,
              minChildSize: 0.7,
              maxChildSize: 0.92,
              snap: true,
              snapSizes: const [0.82, 0.92],
              builder: (context, scrollController) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white),
                  ),
                  child: _BookingForm(
                    scrollController: scrollController,
                    serviceName: serviceName,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BookingForm extends StatefulWidget {
  const _BookingForm({
    required this.scrollController,
    required this.serviceName,
  });

  final ScrollController scrollController;
  final String serviceName;

  @override
  State<_BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<_BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: gold,
            onPrimary: navy,
            surface: Colors.white,
            onSurface: navy,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: gold,
            onPrimary: navy,
            surface: Colors.white,
            onSurface: navy,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    controller: widget.scrollController,
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Text(
            'Book Your Service',
            style: TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your details and we will confirm your appointment.',
            style: TextStyle(color: Color(0xFF5E6874), fontSize: 11),
          ),
          const SizedBox(height: 16),
          _TextField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline),
          const SizedBox(height: 10),
          _TextField(
            label: 'Mobile Number',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          _TextField(
            label: 'Service Address',
            controller: _addressController,
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PickerField(
                  label: 'Preferred Date',
                  controller: _dateController,
                  icon: Icons.calendar_month_outlined,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PickerField(
                  label: 'Preferred Time',
                  controller: _timeController,
                  icon: Icons.access_time,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _TextField(
            label: 'Project Details / Notes',
            controller: _notesController,
            icon: Icons.edit_note_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                try {
                  final bookingId = await BookingService().submitBooking(
                    customerName: _nameController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                    serviceName: widget.serviceName,
                    preferredDate: _dateController.text,
                    preferredTime: _timeController.text,
                    notes: _notesController.text,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: navy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: gold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${widget.serviceName} appointment scheduled successfully!',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );

                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 6),
                      contentPadding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
                      actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      title: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFF22C55E)]),
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Appointment Scheduled',
                              style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBF0),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: gold.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: gold, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.serviceName,
                                        style: const TextStyle(color: navy, fontSize: 13.5, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_dateController.text} • ${_timeController.text}',
                                        style: const TextStyle(color: Color(0xFF657180), fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Request #${bookingId.padLeft(4, '0').substring(0, 6)}',
                                        style: const TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),                          const SizedBox(height: 14),
                          const Text(
                            'Our admin team will review your request and share a technician and confirmation shortly.',
                            style: TextStyle(color: Color(0xFF5E6874), fontSize: 12.5, height: 1.45),
                          ),
                        ],
                      ),
                      actions: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.check_rounded, size: 17),
                            label: const Text('Done'),
                            style: FilledButton.styleFrom(
                              backgroundColor: navy,
                              foregroundColor: goldLight,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFFB91C1C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Could not submit booking: $error',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Submit Booking'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                backgroundColor: gold,
                foregroundColor: navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter $label' : null,
    style: const TextStyle(color: navy, fontSize: 12),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 17),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E5EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E5EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    ),
  );
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    readOnly: true,
    onTap: onTap,
    validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter $label' : null,
    style: const TextStyle(color: navy, fontSize: 12),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 17),
      suffixIcon: const Icon(Icons.arrow_drop_down, color: navy),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E5EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E5EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    ),
  );
}

class _StepData {
  const _StepData(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

class _BenefitData {
  const _BenefitData(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}
