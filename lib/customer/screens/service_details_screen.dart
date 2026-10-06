import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_page_route.dart';
import 'hvac_installation.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.steps,
    required this.benefits,
  });

  final String title;
  final String description;
  final List<ServiceStep> steps;
  final List<ServiceBenefit> benefits;

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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: navy.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: navy.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    title.toUpperCase(),
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
            Positioned(
              top: 8,
              right: 8,
              child: _CircleButton(
                icon: Icons.notifications_none,
                tooltip: 'Notifications',
                iconColor: goldLight,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You are all caught up.')),
                  );
                },
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
                  child: _DetailsPanel(
                    title: title,
                    description: description,
                    steps: steps,
                    benefits: benefits,
                    controller: scrollController,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.title,
    required this.description,
    required this.steps,
    required this.benefits,
    required this.controller,
  });

  final String title;
  final String description;
  final List<ServiceStep> steps;
  final List<ServiceBenefit> benefits;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      border: Border.all(color: const Color(0xFFEDEFF4)),
      boxShadow: [
        BoxShadow(
          color: navy.withValues(alpha: 0.18),
          blurRadius: 16,
          offset: const Offset(0, -4),
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
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5E6874),
              fontSize: 10.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const _SectionTitle('Process'),
          const SizedBox(height: 6),
          Column(
            children: steps
                .asMap()
                .entries
                .map(
                  (entry) => _TimelineRow(
                    index: entry.key + 1,
                    data: entry.value,
                    isLast: entry.key == steps.length - 1,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 9),
          const _SectionTitle('Why Choose Us'),
          const SizedBox(height: 7),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: benefits.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (_, index) => _BenefitItem(data: benefits[index]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                appPageRoute<void>(
                  AppointmentBookingScreen(serviceName: title),
                ),
              ),
              icon: const Icon(Icons.calendar_month_outlined, size: 15),
              label: const Text('Schedule Service'),
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
  final ServiceStep data;
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

  final ServiceBenefit data;

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

class ServiceStep {
  const ServiceStep(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

class ServiceBenefit {
  const ServiceBenefit(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}
