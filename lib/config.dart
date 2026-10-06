import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Configuration for AL TAQWA Cooling System Landing Website.
/// Change these URLs to connect with live environments.

/// URL of the live customer panel / web app.
/// Set your real URL here when available.
const customerPanelUrl = 'CUSTOMER_PANEL_URL';

/// Official WhatsApp contact link for Al Taqwa Cooling System.
const whatsappUrl = 'https://wa.me/971506109894';

/// Apple App Store link for the mobile app (leave empty to fall back to Customer Panel).
const appStoreUrl = '';

/// Google Play Store link for the mobile app (leave empty to fall back to Customer Panel).
const playStoreUrl = '';

/// Official brand name
const brandName = 'AL TAQWA Cooling System';

/// Opens the customer panel in a new external browser tab.
/// If the URL is still a placeholder or empty, shows a polite snackbar.
Future<void> openCustomerPanel(BuildContext context) async {
  if (customerPanelUrl.isEmpty ||
      customerPanelUrl == 'CUSTOMER_PANEL_URL' ||
      !customerPanelUrl.startsWith('http')) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFFC9A24A), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Customer panel link coming soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF061A3D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF1E3A8A), width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    return;
  }

  final uri = Uri.parse(customerPanelUrl);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open customer panel link.'),
          backgroundColor: Color(0xFF061A3D),
        ),
      );
    }
  }
}

/// Opens the official WhatsApp chat.
Future<void> openWhatsApp(BuildContext context) async {
  final uri = Uri.parse(whatsappUrl);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp.'),
          backgroundColor: Color(0xFF061A3D),
        ),
      );
    }
  }
}

/// Opens App Store, or falls back to Customer Panel if empty.
Future<void> openAppStore(BuildContext context) async {
  if (appStoreUrl.isNotEmpty && appStoreUrl.startsWith('http')) {
    final uri = Uri.parse(appStoreUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    } catch (_) {}
  }
  if (!context.mounted) return;
  await openCustomerPanel(context);
}

/// Opens Google Play Store, or falls back to Customer Panel if empty.
Future<void> openPlayStore(BuildContext context) async {
  if (playStoreUrl.isNotEmpty && playStoreUrl.startsWith('http')) {
    final uri = Uri.parse(playStoreUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    } catch (_) {}
  }
  if (!context.mounted) return;
  await openCustomerPanel(context);
}
