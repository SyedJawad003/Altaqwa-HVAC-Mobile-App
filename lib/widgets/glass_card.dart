import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/landing_theme.dart';

/// Frosted glass card with backdrop blur and subtle metallic gold/blue highlight.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isHoverable;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 20,
    this.isHoverable = false,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderCol = widget.borderColor ??
        (_isHovered
            ? LandingTheme.gold.withOpacity(0.6)
            : Colors.white.withOpacity(0.12));

    final bgCol = widget.backgroundColor ??
        (_isHovered
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.07));

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bgCol,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderCol, width: 1.3),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: LandingTheme.gold.withOpacity(0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF061A3D).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.isHoverable || widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
