import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/enteral_nutrition_dripping_relevance.dart';

void main() {
  group('isEnteralNutritionDrippingRelevant', () {
    test('enteralNutrition true returns true', () {
      expect(
        isEnteralNutritionDrippingRelevant(
          const CalculatorRelevanceContext(enteralNutrition: true),
        ),
        true,
      );
    });

    test('enteralNutrition false (and everything else false) returns false', () {
      expect(
        isEnteralNutritionDrippingRelevant(
          const CalculatorRelevanceContext(),
        ),
        false,
      );
    });

    test(
      'parenteralNutrition true alone (enteralNutrition false) still '
      'returns false - not gated on the wrong flag',
      () {
        expect(
          isEnteralNutritionDrippingRelevant(
            const CalculatorRelevanceContext(parenteralNutrition: true),
          ),
          false,
        );
      },
    );
  });
}
