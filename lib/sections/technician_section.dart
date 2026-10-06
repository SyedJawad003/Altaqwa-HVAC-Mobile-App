import 'package:flutter/material.dart';
import '../config.dart';
import '../theme/landing_theme.dart';

/// 6. Technician & Service Workflow Section (Deep Blue Section showing Customer - Admin - Technician connectivity).
class TechnicianSection extends StatelessWidget {
  const TechnicianSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      decoration: const BoxDecoration(
        gradient: LandingTheme.blueSectionGradient,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 1200 ? 64 : (screenWidth > 600 ? 32 : 18),
        vertical: isDesktop ? 96 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Visual Diagram
                    Expanded(
                      flex: 11,
                      child: _buildWorkflowVisual(context),
                    ),
                    const SizedBox(width: 56),
                    // Right: Information & Checklist
                    Expanded(
                      flex: 12,
                      child: _buildRightContent(context),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildRightContent(context, centerText: true),
                    const SizedBox(height: 48),
                    _buildWorkflowVisual(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRightContent(BuildContext context, {bool centerText = false}) {
    final checklist = const [
      'Assigned Jobs — Instant dispatch to verified technicians on field',
      'Job Status Updates — Live phase tracking with photo verification',
      'Customer Requests — Transparent service bookings with preferred slots',
      'Service Notifications — Push alerts at each critical service milestone',
      'Service History — Digital invoices, refrigerant logs & maintenance records',
    ];

    return Column(
      crossAxisAlignment:
          centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: LandingTheme.gold.withOpacity(0.5),
            ),
          ),
          child: const Text(
            'TECHNICIAN & FLEET SYNC',
            style: TextStyle(
              color: LandingTheme.goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Headline
        const Text(
          'One Connected Service Platform',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          'Al Taqwa seamlessly connects customers, administrators and field technicians through one coordinated HVAC service platform.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.82),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),

        // Checklist Items
        Column(
          children: checklist.map((item) {
            final split = item.split('—');
            final title = split[0].trim();
            final desc = split.length > 1 ? split[1].trim() : '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: LandingTheme.gold.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: LandingTheme.gold, width: 1.2),
                    ),
                    child: const Icon(Icons.check,
                        color: LandingTheme.gold, size: 13),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$title — ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: desc,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.72),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // CTA
        ElevatedButton.icon(
          onPressed: () => openCustomerPanel(context),
          icon: const Icon(Icons.dashboard_customize_outlined,
              color: Color(0xFF061A3D), size: 17),
          label: const Text(
            'Explore Connected Platform',
            style: TextStyle(
              color: Color(0xFF061A3D),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: LandingTheme.gold,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  /// Interactive Workflow Diagram: Customer -> Admin -> Technician -> Customer
  Widget _buildWorkflowVisual(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF040E22).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: LandingTheme.gold.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: const Color(0xFF0B3A8C).withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          // Step 1: Customer Node
          _buildNode(
            icon: Icons.person_pin_circle_outlined,
            role: 'CUSTOMER',
            action: 'Submits AC Service Request via App',
            isGold: false,
          ),

          _buildConnectingFlow('Service Request Dispatched'),

          // Step 2: Admin Node
          _buildNode(
            icon: Icons.admin_panel_settings_outlined,
            role: 'ADMINISTRATOR',
            action: 'Reviews, Verifies & Assigns Certified Tech',
            isGold: true,
          ),

          _buildConnectingFlow('Technician Assigned with Spares & Fleet'),

          // Step 3: Technician Node
          _buildNode(
            icon: Icons.engineering_outlined,
            role: 'TECHNICIAN',
            action: 'Executes On-Site Job & Logs Diagnostics',
            isGold: false,
          ),

          _buildConnectingFlow('Live Status Updated & Sign-off Recorded'),

          // Step 4: Customer Loop Complete
          _buildNode(
            icon: Icons.verified_user_outlined,
            role: 'CUSTOMER PORTAL',
            action: 'Receives Completion Report & Invoice',
            isGold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNode({
    required IconData icon,
    required String role,
    required String action,
    required bool isGold,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isGold
            ? const Color(0xFF0B2B63)
            : const Color(0xFF061A3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGold ? LandingTheme.gold : const Color(0xFF1E3A8A),
          width: isGold ? 1.5 : 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isGold ? LandingTheme.gold : const Color(0xFF0B3A8C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isGold ? const Color(0xFF061A3D) : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    color: isGold ? LandingTheme.goldLight : Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  action,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingFlow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_downward, color: LandingTheme.gold, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
