import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_page_route.dart';
import 'service_details_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const services = [
    _ServiceData(
      'HVAC Installation',
      'Professional installation of all types of AC systems.',
      Icons.ac_unit_outlined,
      [
        ServiceStep('Site Inspection', 'We assess your space and cooling requirements.', Icons.search_outlined),
        ServiceStep('System Selection', 'We recommend the ideal system for your property.', Icons.tune_outlined),
        ServiceStep('Professional Installation', 'Installed safely and efficiently by certified specialists.', Icons.build_outlined),
        ServiceStep('Testing & Handover', 'Tested, tuned, and ready for use.', Icons.fact_check_outlined),
      ],
      [
        ServiceBenefit('Professional Technicians', 'Skilled experts handle every detail.', Icons.engineering_outlined),
        ServiceBenefit('Quality Equipment', 'Reliable systems built to perform.', Icons.verified_outlined),
        ServiceBenefit('Proper Installation', 'Careful setup for lasting comfort.', Icons.home_repair_service_outlined),
        ServiceBenefit('After-Installation Support', 'We remain available when you need us.', Icons.support_agent_outlined),
      ],
    ),
    _ServiceData(
      'HVAC Maintenance',
      'Routine maintenance for smooth & efficient performance.',
      Icons.settings_suggest_outlined,
      [
        ServiceStep('Inspection', 'We check filters, coils, and airflow performance.', Icons.search_outlined),
        ServiceStep('Cleaning', 'We clean key components for better efficiency.', Icons.cleaning_services_outlined),
        ServiceStep('Performance Check', 'We verify system output and cooling balance.', Icons.speed_outlined),
        ServiceStep('Final Report', 'We recommend the next steps for long-term reliability.', Icons.fact_check_outlined),
      ],
      [
        ServiceBenefit('Energy Savings', 'Optimized performance reduces power consumption.', Icons.energy_savings_leaf_outlined),
        ServiceBenefit('Longer Lifespan', 'Regular care keeps systems running longer.', Icons.timelapse_outlined),
        ServiceBenefit('Better Air Quality', 'Clean systems improve indoor comfort and hygiene.', Icons.air_outlined),
        ServiceBenefit('Priority Support', 'Scheduled care means faster service when needed.', Icons.support_agent_outlined),
      ],
    ),
    _ServiceData(
      'HVAC Repair',
      'Quick and reliable repair services for all AC brands.',
      Icons.build_outlined,
      [
        ServiceStep('Fault Diagnosis', 'We inspect the unit and identify the root cause.', Icons.search_outlined),
        ServiceStep('Repair Planning', 'We explain the issue and the most efficient fix.', Icons.tune_outlined),
        ServiceStep('Repair Execution', 'We restore performance with quality parts and tools.', Icons.build_outlined),
        ServiceStep('System Testing', 'We verify cooling output and full functionality.', Icons.fact_check_outlined),
      ],
      [
        ServiceBenefit('Fast Response', 'Quick diagnosis and timely service calls.', Icons.speed_outlined),
        ServiceBenefit('Trusted Repairs', 'Solutions tailored to your system and brand.', Icons.verified_outlined),
        ServiceBenefit('Quality Parts', 'Reliable components ensure lasting performance.', Icons.precision_manufacturing_outlined),
        ServiceBenefit('Comfort Restored', 'Your space returns to stable, dependable cooling.', Icons.home_outlined),
      ],
    ),
    _ServiceData(
      'Ducting Services',
      'High-quality ducting solutions for better airflow & efficiency.',
      Icons.alt_route_outlined,
      [
        ServiceStep('Layout Review', 'We assess the airflow path and design needs.', Icons.route_outlined),
        ServiceStep('Duct Planning', 'We map custom duct work for balance and efficiency.', Icons.design_services_outlined),
        ServiceStep('Installation', 'We fit and seal ducts for improved airflow.', Icons.build_outlined),
        ServiceStep('Airflow Testing', 'We verify temperature balance and ventilation.', Icons.fact_check_outlined),
      ],
      [
        ServiceBenefit('Efficient Airflow', 'Improved circulation for even cooling.', Icons.air_outlined),
        ServiceBenefit('Energy Efficiency', 'Well-sealed ducts reduce wasted conditioning.', Icons.energy_savings_leaf_outlined),
        ServiceBenefit('Clean Design', 'Neat installations protect your space and performance.', Icons.architecture_outlined),
        ServiceBenefit('Comfort Balance', 'Consistent airflow across every room.', Icons.home_outlined),
      ],
    ),
    _ServiceData(
      'Ventilation Solutions',
      'Advanced ventilation systems for fresh and clean air.',
      Icons.air_outlined,
      [
        ServiceStep('Air Quality Check', 'We assess ventilation needs and airflow patterns.', Icons.search_outlined),
        ServiceStep('System Design', 'We recommend custom solutions for healthier air.', Icons.tune_outlined),
        ServiceStep('Installation', 'We fit efficient ventilation units and duct paths.', Icons.build_outlined),
        ServiceStep('Final Testing', 'We confirm proper airflow and performance.', Icons.fact_check_outlined),
      ],
      [
        ServiceBenefit('Fresh Air', 'Improves indoor comfort and wellbeing.', Icons.air_outlined),
        ServiceBenefit('Clean Environment', 'Supports healthier indoor air quality.', Icons.cleaning_services_outlined),
        ServiceBenefit('Smart Control', 'Balanced airflow for busy spaces.', Icons.settings_suggest_outlined),
        ServiceBenefit('Reliable Operation', 'Built for long-term performance and durability.', Icons.verified_outlined),
      ],
    ),
    _ServiceData(
      'Commercial HVAC',
      'Tailored HVAC solutions for offices, shops & large buildings.',
      Icons.business_outlined,
      [
        ServiceStep('Site Evaluation', 'We inspect your commercial space and requirements.', Icons.search_outlined),
        ServiceStep('System Planning', 'We design a setup that supports your workload and layout.', Icons.business_outlined),
        ServiceStep('Installation', 'We deliver dependable commercial-grade setup.', Icons.build_outlined),
        ServiceStep('Performance Review', 'We test the system for comfort and efficiency.', Icons.fact_check_outlined),
      ],
      [
        ServiceBenefit('Commercial Expertise', 'Solutions for offices, shops, and large properties.', Icons.business_outlined),
        ServiceBenefit('Operational Efficiency', 'Reliable performance for busy environments.', Icons.speed_outlined),
        ServiceBenefit('Scalable Systems', 'Tailored capacity for your growing demands.', Icons.expand_outlined),
        ServiceBenefit('Support Coverage', 'Ongoing care for uninterrupted business comfort.', Icons.support_agent_outlined),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/menu_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, error, stackTrace) =>
                Container(color: Colors.white),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 66, 18, 0),
                child: Text(
                  'Our Services',
                  style: TextStyle(
                    color: navy,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 6, 18, 0),
                child: Text(
                  'Reliable HVAC solutions for every need.',
                  style: TextStyle(color: Color(0xFF5E6874), fontSize: 15),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ClipRect(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...services.map(
                          (service) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: _ServiceCard(service: service),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _SupportCard(
                          onPressed: () => _showMessage(
                            context,
                            'We will be in touch soon.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 16,
          child: SafeArea(
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: () => _showMessage(context, 'You are all caught up.'),
              icon: const Icon(Icons.notifications_none, color: goldLight),
              style: IconButton.styleFrom(
                backgroundColor: navy.withValues(alpha: 0.9),
                side: BorderSide(color: gold.withValues(alpha: 0.7)),
              ),
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
  );

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ServiceData {
  const _ServiceData(
    this.title,
    this.description,
    this.icon,
    this.steps,
    this.benefits,
  );

  final String title;
  final String description;
  final IconData icon;
  final List<ServiceStep> steps;
  final List<ServiceBenefit> benefits;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final _ServiceData service;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    elevation: 2,
    shadowColor: navy.withValues(alpha: 0.16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        appPageRoute<void>(
          ServiceDetailScreen(
            title: service.title,
            description: service.description,
            steps: service.steps,
            benefits: service.benefits,
          ),
        ),
      ),
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            Container(
              width: 62,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(service.icon, color: Colors.white, size: 24),
                  const Positioned(
                    right: 11,
                    bottom: 12,
                    child: Icon(Icons.circle, color: gold, size: 4),
                  ),
                ],
              ),
            ),
            Container(width: 2, height: 48, color: gold),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 8, 5, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5E6874),
                        fontSize: 10,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: gold, size: 21),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 19, 16, 17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: navy.withValues(alpha: 0.22), blurRadius: 12),
      ],
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need Help?',
                style: TextStyle(
                  color: navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Our experts are ready to assist you 24/7',
                style: TextStyle(color: Color(0xFF5E6874), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text('Contact Us'),
          style: ElevatedButton.styleFrom(
            backgroundColor: navy,
            foregroundColor: goldLight,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ],
    ),
  );
}
