import 'package:flutter_test/flutter_test.dart';

import 'package:xenosignal/main.dart';

void main() {
  testWidgets('XenoSignal app renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const XenoSignalApp());

    // Verify that the app title is displayed.
    expect(find.text('XENOSIGNAL'), findsOneWidget);

    // Verify theme demo sections are present.
    expect(find.text('TYPOGRAPHY'), findsOneWidget);
    expect(find.text('COLOR PALETTE'), findsOneWidget);
    expect(find.text('SIGNAL STRENGTH'), findsOneWidget);
    expect(find.text('CONTROLS'), findsOneWidget);
    expect(find.text('DISPLAY SETTINGS'), findsOneWidget);
  });
}
