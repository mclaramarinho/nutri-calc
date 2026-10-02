import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_date_time_picker/ds_date_time_picker.dart';

/// Pumps a bare [MaterialApp] hosting a single [DsDateTimePicker].
Future<void> _pumpPicker(
  WidgetTester tester, {
  DateTime? value,
  bool disabled = false,
  required ValueChanged<DateTime?> onChanged,
  ValueChanged<bool>? onValidityChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DsDateTimePicker(
          value: value,
          disabled: disabled,
          onChanged: onChanged,
          onValidityChanged: onValidityChanged,
        ),
      ),
    ),
  );
}

void main() {
  group('DsDateTimePicker', () {
    testWidgets('empty state shows hint and default helper text', (
      tester,
    ) async {
      await _pumpPicker(tester, onChanged: (_) {});

      expect(find.text('Selecionar data e hora'), findsOneWidget);
      expect(
        find.text('Se não selecionado, será usado o momento do registro.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('filled state shows formatted value and a clear icon', (
      tester,
    ) async {
      final value = DateTime(2024, 3, 10, 9, 30);
      await _pumpPicker(tester, value: value, onChanged: (_) {});

      expect(find.text('10/03/2024 - 09:30'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tapping clear calls onChanged(null)', (tester) async {
      final value = DateTime(2024, 3, 10, 9, 30);
      DateTime? changedTo = value;
      bool? validity;

      await _pumpPicker(
        tester,
        value: value,
        onChanged: (v) => changedTo = v,
        onValidityChanged: (v) => validity = v,
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(changedTo, isNull);
      expect(validity, isFalse);
    });

    testWidgets('disabled blocks the tap from opening a picker', (
      tester,
    ) async {
      await _pumpPicker(tester, disabled: true, onChanged: (_) {});

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // No native date picker dialog should have been opened.
      expect(find.byType(DatePickerDialog), findsNothing);
    });
  });

  group('DsDateTimePicker.combineAndValidate', () {
    test('accepts a combined moment before maxDateTime', () {
      final maxDateTime = DateTime(2024, 3, 10, 12, 0);
      final result = DsDateTimePicker.combineAndValidate(
        date: DateTime(2024, 3, 10),
        time: const TimeOfDay(hour: 9, minute: 30),
        maxDateTime: maxDateTime,
      );

      expect(result, DateTime(2024, 3, 10, 9, 30));
    });

    test('accepts a combined moment on an earlier day regardless of time', () {
      final maxDateTime = DateTime(2024, 3, 10, 8, 0);
      final result = DsDateTimePicker.combineAndValidate(
        date: DateTime(2024, 3, 9),
        time: const TimeOfDay(hour: 23, minute: 59),
        maxDateTime: maxDateTime,
      );

      expect(result, DateTime(2024, 3, 9, 23, 59));
    });

    test(
      'rejects a combined moment on the same day as maxDateTime but later',
      () {
        final maxDateTime = DateTime(2024, 3, 10, 8, 0);
        final result = DsDateTimePicker.combineAndValidate(
          date: DateTime(2024, 3, 10),
          time: const TimeOfDay(hour: 9, minute: 0),
          maxDateTime: maxDateTime,
        );

        expect(result, isNull);
      },
    );
  });
}
