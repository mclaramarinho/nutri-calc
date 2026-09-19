import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_definition.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/presentation/widgets/calculator_list.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_placeholder/ds_placeholder.dart';

Widget wrap(Widget child) => MaterialApp(
  home: Builder(
    builder: (context) {
      DsScreenAdapter.init(context);
      return Scaffold(body: child);
    },
  ),
);

void main() {
  group('CalculatorList', () {
    testWidgets(
      'default view renders only relevant calculators, no group headers',
      (tester) async {
        final tapped = <String>[];
        final definitions = [
          CalculatorDefinition(
            id: 'bmi',
            type: CalculatorType.bmi,
            name: 'IMC',
            isRelevant: (_) => true,
            onTap: (_) => tapped.add('bmi'),
          ),
          CalculatorDefinition(
            id: 'energy',
            type: CalculatorType.energyExpenditure,
            name: 'Gasto Energético',
            isRelevant: (_) => false,
            onTap: (_) => tapped.add('energy'),
          ),
        ];

        await tester.pumpWidget(
          wrap(
            CalculatorList(
              definitions: definitions,
              relevanceContext: const CalculatorRelevanceContext(),
            ),
          ),
        );

        expect(find.byType(DsListTile), findsOneWidget);
        expect(find.text('IMC'), findsOneWidget);
        expect(find.text('Gasto Energético'), findsNothing);
        expect(find.byType(DsButton), findsOneWidget);
        expect(find.text('Ver todas as calculadoras'), findsOneWidget);
      },
    );

    testWidgets('toggle button flips label and content on tap', (
      tester,
    ) async {
      // Definition `name` deliberately differs from the CalculatorType
      // `label` here so tile titles and group headers can be told apart by
      // text alone.
      final definitions = [
        CalculatorDefinition(
          id: 'bmi',
          type: CalculatorType.bmi,
          name: 'Calculadora de IMC',
          isRelevant: (_) => true,
          onTap: (_) {},
        ),
        CalculatorDefinition(
          id: 'energy',
          type: CalculatorType.energyExpenditure,
          name: 'Calculadora de Gasto Energético',
          isRelevant: (_) => false,
          onTap: (_) {},
        ),
      ];

      await tester.pumpWidget(
        wrap(
          CalculatorList(
            definitions: definitions,
            relevanceContext: const CalculatorRelevanceContext(),
          ),
        ),
      );

      expect(find.text('Ver todas as calculadoras'), findsOneWidget);
      expect(find.text('Calculadora de Gasto Energético'), findsNothing);

      await tester.tap(find.byType(DsButton));
      await tester.pumpAndSettle();

      expect(find.text('Ver apenas relevantes'), findsOneWidget);
      expect(find.text('Calculadora de Gasto Energético'), findsOneWidget);
      expect(find.text('Calculadora de IMC'), findsOneWidget);

      await tester.tap(find.byType(DsButton));
      await tester.pumpAndSettle();

      expect(find.text('Ver todas as calculadoras'), findsOneWidget);
      expect(find.text('Calculadora de Gasto Energético'), findsNothing);
    });

    testWidgets(
      'expanded view groups by CalculatorType.label in canonical order, '
      'skipping empty-type groups (no header)',
      (tester) async {
        final definitions = [
          CalculatorDefinition(
            id: 'weight-loss',
            type: CalculatorType.weightLossClassification,
            name: 'Calculadora de Perda de Peso',
            isRelevant: (_) => false,
            onTap: (_) {},
          ),
          CalculatorDefinition(
            id: 'bmi',
            type: CalculatorType.bmi,
            name: 'Calculadora de IMC',
            isRelevant: (_) => false,
            onTap: (_) {},
          ),
        ];

        await tester.pumpWidget(
          wrap(
            CalculatorList(
              definitions: definitions,
              relevanceContext: const CalculatorRelevanceContext(),
            ),
          ),
        );

        await tester.tap(find.byType(DsButton));
        await tester.pumpAndSettle();

        // bmi.label appears before weightLossClassification.label in the
        // widget tree, matching CalculatorType.values canonical order.
        final bmiHeaderFinder = find.text(CalculatorType.bmi.label);
        final weightLossHeaderFinder = find.text(
          CalculatorType.weightLossClassification.label,
        );
        expect(bmiHeaderFinder, findsOneWidget);
        expect(weightLossHeaderFinder, findsOneWidget);

        final bmiHeaderPos = tester.getTopLeft(bmiHeaderFinder).dy;
        final weightLossHeaderPos = tester
            .getTopLeft(weightLossHeaderFinder)
            .dy;
        expect(bmiHeaderPos, lessThan(weightLossHeaderPos));

        // No header rendered for empty-type groups: only 2 headers total
        // (bmi + weightLossClassification), no header text for any other
        // CalculatorType label.
        for (final type in CalculatorType.values) {
          if (type == CalculatorType.bmi ||
              type == CalculatorType.weightLossClassification) {
            continue;
          }
          expect(find.text(type.label), findsNothing);
        }
      },
    );

    testWidgets(
      'empty relevant list shows placeholder message with toggle still '
      'visible',
      (tester) async {
        final definitions = [
          CalculatorDefinition(
            id: 'bmi',
            type: CalculatorType.bmi,
            name: 'IMC',
            isRelevant: (_) => false,
            onTap: (_) {},
          ),
        ];

        await tester.pumpWidget(
          wrap(
            CalculatorList(
              definitions: definitions,
              relevanceContext: const CalculatorRelevanceContext(),
            ),
          ),
        );

        expect(find.byType(DsPlaceholder), findsOneWidget);
        expect(
          find.text('Nenhuma calculadora relevante no momento.'),
          findsOneWidget,
        );
        expect(find.byType(DsButton), findsOneWidget);
      },
    );

    testWidgets(
      'entirely empty registry shows placeholder and renders no group '
      'headers when expanded',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            CalculatorList(
              definitions: const [],
              relevanceContext: const CalculatorRelevanceContext(),
            ),
          ),
        );

        expect(find.byType(DsPlaceholder), findsOneWidget);
        expect(
          find.text('Nenhuma calculadora relevante no momento.'),
          findsOneWidget,
        );
        expect(find.byType(DsListTile), findsNothing);

        await tester.tap(find.byType(DsButton));
        await tester.pumpAndSettle();

        expect(find.text('Ver apenas relevantes'), findsOneWidget);
        expect(find.byType(DsListTile), findsNothing);
        for (final type in CalculatorType.values) {
          expect(find.text(type.label), findsNothing);
        }
      },
    );

    testWidgets('tapping a tile invokes that definition onTap', (
      tester,
    ) async {
      var tapped = false;
      final definitions = [
        CalculatorDefinition(
          id: 'bmi',
          type: CalculatorType.bmi,
          name: 'IMC',
          isRelevant: (_) => true,
          onTap: (_) => tapped = true,
        ),
      ];

      await tester.pumpWidget(
        wrap(
          CalculatorList(
            definitions: definitions,
            relevanceContext: const CalculatorRelevanceContext(),
          ),
        ),
      );

      await tester.tap(find.text('IMC'));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });
}
