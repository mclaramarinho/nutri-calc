import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/glucose_infusion_rate_relevance.dart';

void main() {
  group('isGlucoseInfusionRateRelevant', () {
    test('parenteralNutrition true returns true', () {
      expect(
        isGlucoseInfusionRateRelevant(
          const CalculatorRelevanceContext(parenteralNutrition: true),
        ),
        true,
      );
    });

    test(
      'parenteralNutrition false (and everything else false) returns false',
      () {
        expect(
          isGlucoseInfusionRateRelevant(const CalculatorRelevanceContext()),
          false,
        );
      },
    );

    test(
      'enteralNutrition true alone (parenteralNutrition false) still '
      'returns false - not gated on the wrong flag',
      () {
        expect(
          isGlucoseInfusionRateRelevant(
            const CalculatorRelevanceContext(enteralNutrition: true),
          ),
          false,
        );
      },
    );
  });
}
