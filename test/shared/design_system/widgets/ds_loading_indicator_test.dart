import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_sizing.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_loading_indicator/ds_loading_indicator.dart';

/// Pumps a bare [MaterialApp] hosting a single [DsLoadingIndicator],
/// initializing [DsScreenAdapter] first (`DsSizing`'s `.w` extension throws
/// `LateInitializationError` otherwise - same pattern as
/// `ds_checkbox_test.dart`).
Future<void> _pumpIndicator(
  WidgetTester tester, {
  DsLoadingIndicatorVariant variant = DsLoadingIndicatorVariant.page,
  Color? color,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          DsScreenAdapter.init(context);
          return Scaffold(
            body: DsLoadingIndicator(variant: variant, color: color),
          );
        },
      ),
    ),
  );
}

void main() {
  group('DsLoadingIndicator', () {
    testWidgets(
      'page variant renders a 48x48, strokeWidth 4, blue spinner wrapped '
      'in Center',
      (tester) async {
        await _pumpIndicator(tester);

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, DsSizing.loadingIndicatorPage);
        expect(sizedBox.height, DsSizing.loadingIndicatorPage);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 4.0);
        expect(indicator.color, DsColors.blue);

        expect(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(Center),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'inline variant renders a 20x20, strokeWidth 2.5, white spinner with '
      'no Center ancestor',
      (tester) async {
        await _pumpIndicator(tester, variant: DsLoadingIndicatorVariant.inline);

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, DsSizing.loadingIndicatorInline);
        expect(sizedBox.height, DsSizing.loadingIndicatorInline);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 2.5);
        expect(indicator.color, DsColors.white);

        expect(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(Center),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'explicit color overrides the page variant default',
      (tester) async {
        await _pumpIndicator(tester, color: Colors.red);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, Colors.red);
      },
    );

    testWidgets(
      'explicit color overrides the inline variant default',
      (tester) async {
        await _pumpIndicator(
          tester,
          variant: DsLoadingIndicatorVariant.inline,
          color: Colors.red,
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, Colors.red);
      },
    );
  });
}
