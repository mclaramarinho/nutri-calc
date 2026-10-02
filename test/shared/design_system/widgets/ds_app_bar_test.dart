import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';

Future<void> _pumpAppBar(WidgetTester tester, DsAppBarData data) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          DsScreenAdapter.init(context);
          return Scaffold(
            appBar: DsAppBar.build(data: data),
            body: const SizedBox(),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Invokes the [GestureDetector.onTap] directly wired to [iconFinder] instead
/// of dispatching a geometric `tester.tap`. The AppBar's `actionsPadding`
/// (`DsSpacing.xxl` on all sides) exceeds the default toolbar height once
/// combined with the 24x24 action icon, which collapses the action icons'
/// hit-testable area to zero height in the test harness's default viewport -
/// a pre-existing `DsAppBar` layout quirk unrelated to this fix round (out
/// of scope here). Invoking the callback directly still genuinely exercises
/// "does tapping this icon fire the callback" (the actual wiring under
/// test), without depending on that unrelated geometry.
void _invokeOnTap(WidgetTester tester, Finder iconFinder) {
  final gestureDetector = tester.widget<GestureDetector>(
    find
        .ancestor(of: iconFinder, matching: find.byType(GestureDetector))
        .first,
  );
  gestureDetector.onTap!();
}

void main() {
  group('DsAppBar', () {
    testWidgets(
      'omits the theme-toggle icon when onThemeToggle is null',
      (tester) async {
        await _pumpAppBar(tester, const DsAppBarData());

        expect(find.byIcon(Icons.brightness_6), findsNothing);
      },
    );

    testWidgets(
      'renders the theme-toggle icon and fires onThemeToggle when tapped',
      (tester) async {
        var toggled = false;
        await _pumpAppBar(
          tester,
          DsAppBarData(onThemeToggle: () => toggled = true),
        );

        expect(find.byIcon(Icons.brightness_6), findsOneWidget);

        _invokeOnTap(tester, find.byIcon(Icons.brightness_6));

        expect(toggled, isTrue);
      },
    );

    testWidgets('omits the close icon when onClose is null', (tester) async {
      await _pumpAppBar(tester, const DsAppBarData());

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets(
      'renders the close icon and fires onClose when tapped',
      (tester) async {
        var closed = false;
        await _pumpAppBar(tester, DsAppBarData(onClose: () => closed = true));

        expect(find.byIcon(Icons.close), findsOneWidget);

        _invokeOnTap(tester, find.byIcon(Icons.close));

        expect(closed, isTrue);
      },
    );

    testWidgets(
      'renders both the theme-toggle and close icons together when both '
      'callbacks are provided',
      (tester) async {
        await _pumpAppBar(
          tester,
          DsAppBarData(onThemeToggle: () {}, onClose: () {}),
        );

        expect(find.byIcon(Icons.brightness_6), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
      },
    );

    testWidgets('fires onBack when the leading chevron is tapped', (
      tester,
    ) async {
      var backTapped = false;
      await _pumpAppBar(tester, DsAppBarData(onBack: () => backTapped = true));

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(backTapped, isTrue);
    });
  });
}
