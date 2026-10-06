import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:altaqwa_app/landing_page.dart';

void main() {
  testWidgets('Landing page renders title and brand name', (WidgetTester tester) async {
    await tester.pumpWidget(const AlTaqwaLandingApp());
    await tester.pump();

    // Verify Brand Name & Headline
    expect(find.text('AL TAQWA'), findsWidgets);
    expect(find.text('Your Cooling.'), findsOneWidget);
    expect(find.text('Our Care.'), findsOneWidget);
  });
}
