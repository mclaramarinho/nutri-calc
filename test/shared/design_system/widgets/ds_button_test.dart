import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';

/// Pumps a bare [MaterialApp] hosting a single [DsButton].
Future<void> _pumpButton(
  WidgetTester tester, {
  required bool isLoading,
  bool disabled = false,
  required VoidCallback onTap,
  String label = 'Save',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DsButton(
          label: label,
          isLoading: isLoading,
          disabled: disabled,
          onTap: onTap,
        ),
      ),
    ),
  );
}

void main() {
  group('DsButton', () {
    testWidgets(
      'fires onTap when tapped with the default isLoading: false, '
      'disabled: false',
      (tester) async {
        var tapped = false;

        await _pumpButton(
          tester,
          isLoading: false,
          onTap: () => tapped = true,
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'does not fire onTap and renders as disabled when disabled: true, '
      'isLoading: false',
      (tester) async {
        var tapped = false;

        await _pumpButton(
          tester,
          isLoading: false,
          disabled: true,
          onTap: () => tapped = true,
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);

        await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
        await tester.pump();

        expect(tapped, isFalse);
        expect(find.text('Save'), findsOneWidget);
      },
    );

    testWidgets(
      'does not fire onTap and shows a spinner instead of the label when '
      'isLoading: true',
      (tester) async {
        var tapped = false;

        await _pumpButton(
          tester,
          isLoading: true,
          onTap: () => tapped = true,
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);

        await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
        await tester.pump();

        expect(tapped, isFalse);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Save'), findsNothing);
      },
    );

    testWidgets(
      'does not fire onTap and shows a spinner when isLoading: true and '
      'disabled: true are combined',
      (tester) async {
        var tapped = false;

        await _pumpButton(
          tester,
          isLoading: true,
          disabled: true,
          onTap: () => tapped = true,
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);

        await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
        await tester.pump();

        expect(tapped, isFalse);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Save'), findsNothing);
      },
    );
  });
}
