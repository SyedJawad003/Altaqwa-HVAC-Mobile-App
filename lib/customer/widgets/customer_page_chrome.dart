import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomerPageBackground extends StatelessWidget {
  const CustomerPageBackground({super.key});

  @override
  Widget build(BuildContext context) => const CustomPaint(
    painter: CustomerPageBackgroundPainter(),
    child: SizedBox.expand(),
  );
}

class CustomerPageBackgroundPainter extends CustomPainter {
  const CustomerPageBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFF4F6F8), BlendMode.src);

    final headerHeight = (size.height * 0.22).clamp(170.0, 220.0).toDouble();
    Path wave(double inset) => Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, headerHeight * 0.76 - inset)
      ..cubicTo(
        size.width * 0.76,
        headerHeight * 1.12 - inset,
        size.width * 0.35,
        headerHeight * 0.68 - inset,
        0,
        headerHeight - inset,
      )
      ..close();

    canvas.drawPath(wave(0), Paint()..color = gold);
    canvas.drawPath(
      wave(4),
      Paint()
        ..shader = navyGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, headerHeight * 1.2),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomerPageBackgroundPainter oldDelegate) =>
      false;
}

class CustomerPageHeader extends StatelessWidget {
  const CustomerPageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 38, 76, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: goldLight,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14),
        ),
      ],
    ),
  );
}

class CustomerPageNotificationButton extends StatelessWidget {
  const CustomerPageNotificationButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Notifications',
    onPressed: onPressed,
    icon: const Icon(Icons.notifications_none, color: goldLight),
    style: IconButton.styleFrom(
      backgroundColor: navy.withValues(alpha: 0.9),
      side: BorderSide(color: gold.withValues(alpha: 0.7)),
    ),
  );
}
