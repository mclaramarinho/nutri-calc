import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';

/// Pumps a bare [MaterialApp] hosting a single [DsCheckbox], initializing
/// [DsScreenAdapter] first (mirrors what `DsScaffold` does in production;
/// `DsSpacing` getters used inside `DsCheckbox` throw
/// `LateInitializationError` otherwise - same pattern as
/// `ds_bottom_sheet_test.dart`).
Future<void> _pumpCheckbox(
  WidgetTester tester, {
  required bool value,
  bool disabled = false,
  String label = 'Hospitalizado',
  String? helperText,
  void Function(bool value)? onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          DsScreenAdapter.init(context);
          return Scaffold(
            body: DsCheckbox(
              label: label,
              value: value,
              disabled: disabled,
              helperText: helperText,
              onChanged: onChanged,
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  group('DsCheckbox', () {
    testWidgets('renders unchecked when value is false', (tester) async {
      await _pumpCheckbox(tester, value: false, onChanged: (_) {});

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('renders checked when value is true', (tester) async {
      await _pumpCheckbox(tester, value: true, onChanged: (_) {});

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets(
      'tapping the Checkbox glyph fires onChanged with the inverted value',
      (tester) async {
        bool? newValue;
        await _pumpCheckbox(
          tester,
          value: false,
          onChanged: (v) => newValue = v,
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(newValue, isTrue);
      },
    );

    testWidgets(
      'tapping the label text also fires onChanged (whole-row tap target)',
      (tester) async {
        bool? newValue;
        await _pumpCheckbox(
          tester,
          value: false,
          label: 'Hospitalizado',
          onChanged: (v) => newValue = v,
        );

        await tester.tap(find.text('Hospitalizado'));
        await tester.pump();

        expect(newValue, isTrue);
      },
    );

    testWidgets(
      'tapping when checked fires onChanged with false (toggles off)',
      (tester) async {
        bool? newValue;
        await _pumpCheckbox(
          tester,
          value: true,
          onChanged: (v) => newValue = v,
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(newValue, isFalse);
      },
    );

    testWidgets(
      'disabled: true blocks taps on both the Checkbox and the row, never '
      'firing onChanged',
      (tester) async {
        var called = false;
        await _pumpCheckbox(
          tester,
          value: false,
          disabled: true,
          label: 'Hospitalizado',
          onChanged: (_) => called = true,
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.onChanged, isNull);

        await tester.tap(find.byType(Checkbox), warnIfMissed: false);
        await tester.pump();
        await tester.tap(find.text('Hospitalizado'), warnIfMissed: false);
        await tester.pump();

        expect(called, isFalse);
      },
    );

    testWidgets(
      'no onChanged provided: row tap target is inert (InkWell.onTap null) '
      'and tapping the label is a safe no-op',
      (tester) async {
        // `onChanged` is nullable for future read-only/display-only use
        // (per docs/design/design-conventions.md); the row-level InkWell
        // must not crash or require a callback when omitted.
        await _pumpCheckbox(tester, value: false, label: 'Hospitalizado');

        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.onTap, isNull);

        // Must not throw even though no onChanged was supplied.
        await tester.tap(find.text('Hospitalizado'), warnIfMissed: false);
        await tester.pump();
      },
    );

    testWidgets('helperText renders when provided', (tester) async {
      await _pumpCheckbox(
        tester,
        value: false,
        onChanged: (_) {},
        helperText: 'Texto de ajuda.',
      );

      expect(find.text('Texto de ajuda.'), findsOneWidget);
    });

    testWidgets('helperText is absent when not provided', (tester) async {
      await _pumpCheckbox(tester, value: false, onChanged: (_) {});

      expect(find.text('Texto de ajuda.'), findsNothing);
    });

    testWidgets('label always renders', (tester) async {
      await _pumpCheckbox(
        tester,
        value: false,
        label: 'Nutrição Enteral',
        onChanged: (_) {},
      );

      expect(find.text('Nutrição Enteral'), findsOneWidget);
    });
  });
}
