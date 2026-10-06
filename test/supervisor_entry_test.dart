import 'package:altaqwa_app/main_supervisor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supervisor app starts at the supervisor login screen', (
    tester,
  ) async {
    await tester.pumpWidget(const SupervisorApp());
    await tester.pumpAndSettle();

    expect(find.text('Al Taqwa Supervisor'), findsOneWidget);
    expect(find.text('Login as Supervisor'), findsOneWidget);
    expect(find.text('Supervisor email'), findsOneWidget);
    expect(find.text('LOG IN'), findsNothing);
  });
}
