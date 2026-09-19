import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/bmi_calculator_relevance.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

void main() {
  group('isBmiRelevant', () {
    test('age null returns false', () {
      expect(isBmiRelevant(const CalculatorRelevanceContext(age: null)), false);
    });

    test('age 18 returns false', () {
      expect(isBmiRelevant(const CalculatorRelevanceContext(age: 18)), false);
    });

    test('age 19 returns true', () {
      expect(isBmiRelevant(const CalculatorRelevanceContext(age: 19)), true);
    });

    test('age 40 returns true', () {
      expect(isBmiRelevant(const CalculatorRelevanceContext(age: 40)), true);
    });
  });
}
