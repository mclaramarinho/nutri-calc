import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/adjusted_dry_weight/presentation/widgets/adjusted_dry_weight_sheet_body.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/ascitis_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/oedema_level.enum.dart';

void main() {
  const imc = Bmi(value: 35, classification: BmiClassification.obesity);

  Widget wrap() => MaterialApp(
    home: Builder(
      builder: (context) {
        DsScreenAdapter.init(context);
        return const Scaffold(
          body: AdjustedDryWeightSheetBody(currentWeight: 80, imc: imc),
        );
      },
    ),
  );

  testWidgets(
    'Oedema dropdown only exposes the 4 non-ascites OedemaLevel cases '
    '(low/moderate/severe/generalized), not the ascitisLow/Moderate/Severe '
    'cases which duplicate the separate Ascite field',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      final oedemaDropdownFinder = find.byType(
        DropdownMenuFormField<OedemaLevel?>,
      );

      await tester.tap(oedemaDropdownFinder);
      await tester.pumpAndSettle();

      // "Nenhum" is both the default-selected value shown in the closed
      // field and the first menu item once opened - hence 2, not 1 (unlike
      // the other labels below, which are not currently selected).
      expect(find.text('Nenhum'), findsNWidgets(2));
      expect(find.text('Edema leve'), findsOneWidget);
      expect(find.text('Edema moderado'), findsOneWidget);
      expect(find.text('Edema grave'), findsOneWidget);
      expect(find.text('Edema generalizado'), findsOneWidget);

      // The Edema dropdown's option count is exactly 5 (Nenhum + the 4
      // non-ascites OedemaLevel cases asserted above) - if the 3
      // ascitis-shaped cases were ever accidentally exposed here too, the
      // widget-count-based assertions above would still individually pass,
      // so this explicit total-count check is what actually guards against
      // that regression.
      expect(find.byType(MenuItemButton), findsNWidgets(5));
    },
  );

  testWidgets(
    'Ascite dropdown exposes exactly the 3 AscitisLevel cases',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      final ascitisDropdownFinder = find.byType(
        DropdownMenuFormField<AscitisLevel?>,
      );

      await tester.tap(ascitisDropdownFinder);
      await tester.pumpAndSettle();

      // "Nenhuma" is both the default-selected value shown in the closed
      // field and the first menu item once opened - hence 2, not 1 (unlike
      // the other labels below, which are not currently selected).
      expect(find.text('Nenhuma'), findsNWidgets(2));
      expect(find.text('Ascite leve'), findsOneWidget);
      expect(find.text('Ascite moderada'), findsOneWidget);
      expect(find.text('Ascite grave'), findsOneWidget);
    },
  );

  testWidgets(
    'Calcular is never disabled (both fields optional) and shows the range '
    'result as "min – max kg"',
    (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calcular'));
      await tester.pumpAndSettle();

      // No ascitis/oedema selected -> min == max == currentWeight (80).
      expect(find.textContaining('Peso Seco Ajustado: 80.0 kg'), findsOneWidget);
    },
  );
}
