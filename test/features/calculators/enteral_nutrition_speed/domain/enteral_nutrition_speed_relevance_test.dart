import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/enteral_nutrition_speed_relevance.dart';

void main() {
  group('isEnteralNutritionSpeedRelevant', () {
    test('enteralNutrition true returns true', () {
      expect(
        isEnteralNutritionSpeedRelevant(
          const CalculatorRelevanceContext(enteralNutrition: true),
        ),
        true,
      );
    });

    test('enteralNutrition false (and everything else false) returns false', () {
      expect(
        isEnteralNutritionSpeedRelevant(const CalculatorRelevanceContext()),
        false,
      );
    });

    test(
      'parenteralNutrition true alone (enteralNutrition false) still '
      'returns false - not gated on the wrong flag',
      () {
        expect(
          isEnteralNutritionSpeedRelevant(
            const CalculatorRelevanceContext(parenteralNutrition: true),
          ),
          false,
        );
      },
    );
  });
}
