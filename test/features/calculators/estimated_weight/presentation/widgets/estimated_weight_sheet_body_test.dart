import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/estimated_weight/presentation/widgets/estimated_weight_sheet_body.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/utils/enums/ethnicity.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

void main() {
  Widget wrap({required int age}) => MaterialApp(
    home: Builder(
      builder: (context) {
        DsScreenAdapter.init(context);
        return Scaffold(body: EstimatedWeightSheetBody(age: age));
      },
    ),
  );

  testWidgets(
    'age > 80 blocks calculation client-side with the age-ceiling message '
    'and keeps Calcular disabled, before ever reaching the use case',
    (tester) async {
      await tester.pumpWidget(wrap(age: 81));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "Peso Estimado é válido apenas para pacientes de até 80 anos.",
        ),
        findsOneWidget,
      );

      expect(
        tester
            .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
            .disabled,
        isTrue,
      );
    },
  );

  testWidgets(
    'age == 80 (boundary) does not block calculation - inline validation '
    'message is not the age one',
    (tester) async {
      await tester.pumpWidget(wrap(age: 80));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "Peso Estimado é válido apenas para pacientes de até 80 anos.",
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'age <= 80 with all fields filled enables Calcular and computing shows '
    'a result',
    (tester) async {
      await tester.pumpWidget(wrap(age: 40));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Altura do Joelho (cm)'),
        '50',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Circunferência do Braço (cm)'),
        '30',
      );

      await tester.tap(find.byType(DropdownMenuFormField<Gender>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Feminino').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownMenuFormField<Ethnicity>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Branca').last);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
            .disabled,
        isFalse,
      );

      await tester.tap(find.text('Calcular'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Peso Estimado:'), findsOneWidget);
    },
  );
}
