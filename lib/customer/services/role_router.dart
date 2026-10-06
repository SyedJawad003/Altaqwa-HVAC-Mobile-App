import 'package:flutter/material.dart';

import '../../supervisor/supervisor_shell.dart';
import '../../technician/technician_dashboard_screen.dart';
import '../screens/home_screen.dart';

Widget appHomeForRole(String role) {
  switch (role.trim().toLowerCase()) {
    case 'technician':
      return const TechnicianDashboardScreen();
    case 'supervisor':
      return const SupervisorShell();
    default:
      return const HomeScreen();
  }
}
