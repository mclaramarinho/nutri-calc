import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/nitrogen_balance_relevance.dart';

void main() {
  group('isNitrogenBalanceRelevant', () {
    test('hospitalized alone returns true', () {
      expect(
        isNitrogenBalanceRelevant(
          const CalculatorRelevanceContext(hospitalized: true),
        ),
        true,
      );
    });

    test('confinedToBed alone returns true', () {
      expect(
        isNitrogenBalanceRelevant(
          const CalculatorRelevanceContext(confinedToBed: true),
        ),
        true,
      );
    });

    test('enteralNutrition alone returns true', () {
      expect(
        isNitrogenBalanceRelevant(
          const CalculatorRelevanceContext(enteralNutrition: true),
        ),
        true,
      );
    });

    test('parenteralNutrition alone returns true', () {
      expect(
        isNitrogenBalanceRelevant(
          const CalculatorRelevanceContext(parenteralNutrition: true),
        ),
        true,
      );
    });

    test('all false returns false', () {
      expect(
        isNitrogenBalanceRelevant(const CalculatorRelevanceContext()),
        false,
      );
    });
  });
}
