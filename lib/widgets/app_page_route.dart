import 'package:flutter/material.dart';

PageRouteBuilder<T> appPageRoute<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (_, animation, secondaryAnimation) => page,
  transitionDuration: const Duration(milliseconds: 350),
  reverseTransitionDuration: const Duration(milliseconds: 250),
  transitionsBuilder: (_, animation, secondaryAnimation, child) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(curve);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(position: slide, child: child),
    );
  },
);
