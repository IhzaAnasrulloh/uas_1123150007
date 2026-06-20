import 'package:flutter_test/flutter_test.dart';
import 'package:gocap/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DompetKampusApp());

    // Verify that the app builds without error
    expect(find.byType(DompetKampusApp), findsOneWidget);
  });
}