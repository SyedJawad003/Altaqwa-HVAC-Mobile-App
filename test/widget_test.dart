// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altaqwa_app/admin/admin_dashboard_screen.dart';
import 'package:altaqwa_app/admin/customers_screen.dart';
import 'package:altaqwa_app/customer/screens/login_screen.dart';
import 'package:altaqwa_app/customer/services/auth_gate.dart';
import 'package:altaqwa_app/customer/services/booking_service.dart';
import 'package:altaqwa_app/supervisor/supervisor_register_screen.dart';

class FakeBookingService extends BookingService {
  FakeBookingService(this._requests);

  final List<BookingRequest> _requests;

  @override
  Stream<List<BookingRequest>> watchBookings() => Stream.value(_requests);
}

void main() {
  testWidgets('app starts on the login screen when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(authStateChanges: Stream<User?>.value(null)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LOG IN'), findsOneWidget);
  });

  testWidgets('customer login screen has no staff sign-in entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('STAFF SIGN-IN'), findsNothing);
  });

  testWidgets('supervisor registration has no customer login entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SupervisorRegisterScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Customer / Technician login'), findsNothing);
  });

  testWidgets('customers screen shows the empty state when no bookings exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomersScreen(bookingService: FakeBookingService(const [])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Customer Activity'), findsOneWidget);
    expect(find.text('No customer bookings found.'), findsOneWidget);
  });

  testWidgets('dashboard customers menu item opens the customer screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminDashboardScreen(bookingService: FakeBookingService(const [])),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();

    expect(find.text('Customer Activity'), findsOneWidget);
  });
}
