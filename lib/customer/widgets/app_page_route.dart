import 'package:flutter/material.dart';

PageRouteBuilder<T> appPageRoute<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (_, animation, secondaryAnimation) => page,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
  transitionsBuilder: (_, _, _, child) => child,
);
