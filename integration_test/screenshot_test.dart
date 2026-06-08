import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_ios_launch_share_perf/src/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Uses fixed pumps (not pumpAndSettle) so the always-on perf animation does
  // not time the capture out.
  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot(name);
  }

  testWidgets('capture screens', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LaunchSharePerfApp()));
    await tester.pumpAndSettle();
    await shoot(tester, '01-home');

    // Native iOS share screen.
    await tester.tap(find.text('Native iOS Share'));
    await tester.pumpAndSettle();
    await shoot(tester, '02-share');
    Navigator.of(tester.element(find.text('Island 03'))).pop();
    await tester.pumpAndSettle();

    // Performance HUD with optimization toggles (animation runs continuously).
    await tester.tap(find.text('Performance HUD'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await shoot(tester, '03-performance');
  });
}
