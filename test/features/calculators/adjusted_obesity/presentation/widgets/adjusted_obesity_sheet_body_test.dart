import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/adjusted_obesity/presentation/widgets/adjusted_obesity_sheet_body.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';

void main() {
  Widget wrap({required double currentWeight, required double idealWeight}) =>
      MaterialApp(
        home: Builder(
          builder: (context) {
            DsScreenAdapter.init(context);
            return Scaffold(
              body: AdjustedObesitySheetBody(
                currentWeight: currentWeight,
                idealWeight: idealWeight,
              ),
            );
          },
        ),
      );

  testWidgets(
    'calculates automatically on open (no manual inputs) and shows the '
    'adjusted weight, with the "considerar para cálculos" checkbox '
    'defaulting to checked',
    (tester) async {
      await tester.pumpWidget(wrap(currentWeight: 100, idealWeight: 70));
      await tester.pumpAndSettle();

      // 70 + (0.4 * (100 - 70)) = 82.0 kg
      expect(find.textContaining('Peso Ajustado: 82.0 kg'), findsOneWidget);

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
    'negative current weight is an invalid param and surfaces the inline '
    'error message instead of a result',
    (tester) async {
      await tester.pumpWidget(wrap(currentWeight: -1, idealWeight: 70));
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível calcular o Peso Ajustado.'),
        findsOneWidget,
      );
      expect(find.textContaining('Peso Ajustado:'), findsNothing);
    },
  );
}
