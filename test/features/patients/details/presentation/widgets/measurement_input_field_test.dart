import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/measurement_input_field.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_date_time_picker/ds_date_time_picker.dart';

Future<void> _pumpField(
  WidgetTester tester, {
  required bool isSaving,
  required bool disabled,
  VoidCallback? saveCallback,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          DsScreenAdapter.init(context);
          return Scaffold(
            body: MeasurementInputField(
              label: 'Peso',
              hint: 'XX.X',
              isSaving: isSaving,
              disabled: disabled,
              saveCallback: saveCallback ?? () {},
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  group('MeasurementInputField', () {
    testWidgets('Save button is disabled when required value field is empty', (
      tester,
    ) async {
      await _pumpField(tester, isSaving: false, disabled: true);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Save button becomes enabled once filled', (tester) async {
      await _pumpField(tester, isSaving: false, disabled: false);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Save button is disabled again mid-save (isSaving true)', (
      tester,
    ) async {
      await _pumpField(tester, isSaving: true, disabled: false);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets(
      'Save button is disabled when the date/time picker reports an '
      'invalid (rejected future-time) selection, even though the value '
      'field is filled',
      (tester) async {
        await _pumpField(tester, isSaving: false, disabled: false);

        // Drive the lifted `_dateTimeInvalid` state directly via the
        // `DsDateTimePicker.onValidityChanged` callback, since simulating a
        // real native date/time-picker rejection isn't practical in a
        // widget test.
        final picker = tester.widget<DsDateTimePicker>(
          find.byType(DsDateTimePicker),
        );
        picker.onValidityChanged!(true);
        await tester.pump();

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      },
    );
  });
}
