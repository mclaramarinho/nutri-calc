import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_definition.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/use_cases/filter_relevant_calculators_use_case.dart';

void main() {
  const filter = FilterRelevantCalculators();
  const context = CalculatorRelevanceContext(age: 30);

  CalculatorDefinition fakeDefinition({
    required String id,
    required bool relevant,
  }) => CalculatorDefinition(
    id: id,
    type: CalculatorType.bmi,
    name: id,
    isRelevant: (_) => relevant,
    onTap: (_) {},
  );

  group('FilterRelevantCalculators', () {
    test('empty input returns empty output', () {
      expect(filter(context, const []), isEmpty);
    });

    test('returns only relevant definitions, preserving order', () {
      final relevantA = fakeDefinition(id: 'a', relevant: true);
      final irrelevant = fakeDefinition(id: 'b', relevant: false);
      final relevantC = fakeDefinition(id: 'c', relevant: true);

      final result = filter(context, [relevantA, irrelevant, relevantC]);

      expect(result, [relevantA, relevantC]);
    });
  });
}
