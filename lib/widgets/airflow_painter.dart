import 'dart:math' as math;
import 'package:flutter/material.dart';

/// HVAC cooling airflow lines and ambient particle animation.
class AirflowBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;
  final Color baseColor;

  const AirflowBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.baseColor = const Color(0xFF4F8FE0),
  });

  @override
  State<AirflowBackground> createState() => _AirflowBackgroundState();
}

class _AirflowBackgroundState extends State<AirflowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AirflowPainter(
            progress: _controller.value,
            baseColor: widget.baseColor,
            showParticles: widget.showParticles,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AirflowPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final bool showParticles;

  _AirflowPainter({
    required this.progress,
    required this.baseColor,
    required this.showParticles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // Draw 3 layered airflow wave streams
    _drawFlowLine(
      canvas,
      size,
      yBaseRatio: 0.28,
      amplitude: 36,
      frequency: 1.4,
      phase: progress * 2 * math.pi,
      strokeWidth: 1.6,
      opacity: 0.12,
      color: baseColor,
    );

    _drawFlowLine(
      canvas,
      size,
      yBaseRatio: 0.45,
      amplitude: 50,
      frequency: 1.1,
      phase: (progress * 2 * math.pi) + 1.2,
      strokeWidth: 2.2,
      opacity: 0.08,
      color: const Color(0xFF86B9F7),
    );

    _drawFlowLine(
      canvas,
      size,
      yBaseRatio: 0.72,
      amplitude: 44,
      frequency: 1.6,
      phase: (progress * 2 * math.pi) + 2.5,
      strokeWidth: 1.4,
      opacity: 0.07,
      color: const Color(0xFFC9A24A), // subtle gold airflow touch
    );

    _drawFlowLine(
      canvas,
      size,
      yBaseRatio: 0.84,
      amplitude: 30,
      frequency: 1.9,
      phase: (progress * 2 * math.pi) + 4.1,
      strokeWidth: 1.0,
      opacity: 0.06,
      color: baseColor,
    );

    if (showParticles) {
      _drawCoolingParticles(canvas, size);
    }
  }

  void _drawFlowLine(
    Canvas canvas,
    Size size, {
    required double yBaseRatio,
    required double amplitude,
    required double frequency,
    required double phase,
    required double strokeWidth,
    required double opacity,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final yBase = size.height * yBaseRatio;
    final step = size.width / 40;

    path.moveTo(0, yBase + math.sin(phase) * amplitude);

    for (double x = 0; x <= size.width; x += step) {
      final normalizedX = x / size.width;
      final y = yBase +
          math.sin(normalizedX * frequency * 2 * math.pi + phase) * amplitude;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawCoolingParticles(Canvas canvas, Size size) {
    // Deterministic subtle particles
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final particleCount = (size.width / 70).clamp(12, 35).toInt();

    for (int i = 0; i < particleCount; i++) {
      final seed = (i * 9301 + 49297) % 233280;
      final relX = (seed / 233280.0);
      final relY = ((seed * 7) % 233280) / 233280.0;

      // Particle vertical gentle oscillation
      final offsetSpeed = ((i % 3) + 1) * 0.8;
      final currentY = (relY + progress * offsetSpeed * 0.15) % 1.0;
      final x = relX * size.width;
      final y = currentY * size.height;

      final radius = (i % 3 == 0) ? 1.8 : ((i % 2 == 0) ? 1.2 : 0.8);
      final isGold = (i % 6 == 0);
      final pColor = isGold
          ? const Color(0xFFC9A24A).withOpacity(0.25)
          : const Color(0xFF93C5FD).withOpacity(0.20);

      particlePaint.color = pColor;
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AirflowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
