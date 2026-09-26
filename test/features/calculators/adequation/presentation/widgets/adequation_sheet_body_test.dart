import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/adequation/presentation/widgets/adequation_sheet_body.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';

void main() {
  Widget wrap({required double currentWeight, required double idealWeight}) =>
      MaterialApp(
        home: Builder(
          builder: (context) {
            DsScreenAdapter.init(context);
            return Scaffold(
              body: AdequationSheetBody(
                currentWeight: currentWeight,
                idealWeight: idealWeight,
              ),
            );
          },
        ),
      );

  testWidgets(
    'calculates automatically on open (no manual inputs) and shows the '
    'value + classification, with the "considerar para cálculos" checkbox '
    'defaulting to checked',
    (tester) async {
      await tester.pumpWidget(wrap(currentWeight: 90, idealWeight: 100));
      await tester.pumpAndSettle();

      // (90 * 100) / 100 = 90.00% -> mildMalnutrition upper boundary (<=90).
      expect(
        find.textContaining('Adequação de Peso: 90.00% (Desnutrição leve)'),
        findsOneWidget,
      );

      expect(
        tester
            .widget<DsCheckbox>(
              find.widgetWithText(
                DsCheckbox,
                'Considerar este peso para cálculos futuros',
              ),
            )
            .value,
        isTrue,
      );
    },
  );

  testWidgets(
    'classifies a value above 120% as Obesidade',
    (tester) async {
      await tester.pumpWidget(wrap(currentWeight: 130, idealWeight: 100));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Adequação de Peso: 130.00% (Obesidade)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'negative ideal weight is an invalid param and surfaces the inline '
    'error message instead of a result',
    (tester) async {
      await tester.pumpWidget(wrap(currentWeight: 90, idealWeight: -1));
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível calcular a Adequação de Peso.'),
        findsOneWidget,
      );
      expect(find.textContaining('Adequação de Peso:'), findsNothing);
    },
  );
}
