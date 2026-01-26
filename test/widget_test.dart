import 'package:flutter_test/flutter_test.dart';

import 'package:xenosignal/main.dart';

void main() {
  testWidgets('XenoSignal app renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const XenoSignalApp());

    // Verify that the app title is displayed.
    expect(find.text('XENOSIGNAL'), findsOneWidget);

    // Verify radar screen elements are present.
    // The radar screen shows blip count in status bar.
    expect(find.textContaining('BLIPS:'), findsOneWidget);

    // Heading readout should show cardinal direction.
    // Initial heading is 0 = North.
    expect(find.text('N'), findsOneWidget);

    // Heatmap legend should be visible.
    expect(find.text('FRESH'), findsOneWidget);
    expect(find.text('HISTORICAL'), findsOneWidget);
  });
}
