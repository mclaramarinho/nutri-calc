import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_sizing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_loading_indicator/ds_loading_indicator.dart';

import '../test_utils/ds_theme_test_utils.dart';

/// Pumps a themed [MaterialApp] hosting a single [DsLoadingIndicator],
/// resolving to [brightness] (see `pumpWidgetWithTheme`).
Future<void> _pumpIndicator(
  WidgetTester tester, {
  DsLoadingIndicatorVariant variant = DsLoadingIndicatorVariant.page,
  Color? color,
  Brightness brightness = Brightness.light,
}) async {
  await pumpWidgetWithTheme(
    tester,
    DsLoadingIndicator(variant: variant, color: color),
    brightness: brightness,
  );
}

void main() {
  group('DsLoadingIndicator', () {
    testWidgets(
      'page variant renders a 48x48, strokeWidth 4, blue spinner wrapped '
      'in Center in light mode',
      (tester) async {
        await _pumpIndicator(tester);

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, DsSizing.loadingIndicatorPage);
        expect(sizedBox.height, DsSizing.loadingIndicatorPage);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 4.0);
        expect(indicator.color, DsColors.light.blue);

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
      'page variant renders a 48x48, strokeWidth 4, blue spinner wrapped '
      'in Center in dark mode',
      (tester) async {
        await _pumpIndicator(tester, brightness: Brightness.dark);

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, DsSizing.loadingIndicatorPage);
        expect(sizedBox.height, DsSizing.loadingIndicatorPage);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 4.0);
        expect(indicator.color, DsColors.dark.blue);

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
      'no Center ancestor in light mode',
      (tester) async {
        await _pumpIndicator(tester, variant: DsLoadingIndicatorVariant.inline);

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, DsSizing.loadingIndicatorInline);
        expect(sizedBox.height, DsSizing.loadingIndicatorInline);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 2.5);
        expect(indicator.color, DsColors.light.white);

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
      'inline variant renders a 20x20, strokeWidth 2.5, white spinner with '
      'no Center ancestor in dark mode',
      (tester) async {
        await _pumpIndicator(
          tester,
          variant: DsLoadingIndicatorVariant.inline,
          brightness: Brightness.dark,
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, DsSizing.loadingIndicatorInline);
        expect(sizedBox.height, DsSizing.loadingIndicatorInline);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 2.5);
        expect(indicator.color, DsColors.dark.white);

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
      'explicit color overrides the page variant default in light mode',
      (tester) async {
        await _pumpIndicator(tester, color: Colors.red);

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, Colors.red);
      },
    );

    testWidgets(
      'explicit color overrides the page variant default in dark mode',
      (tester) async {
        await _pumpIndicator(
          tester,
          color: Colors.red,
          brightness: Brightness.dark,
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, Colors.red);
      },
    );

    testWidgets(
      'explicit color overrides the inline variant default in light mode',
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

    testWidgets(
      'explicit color overrides the inline variant default in dark mode',
      (tester) async {
        await _pumpIndicator(
          tester,
          variant: DsLoadingIndicatorVariant.inline,
          color: Colors.red,
          brightness: Brightness.dark,
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.color, Colors.red);
      },
    );
  });
}
