import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/enteral_nutrition_volume_relevance.dart';

void main() {
  group('isEnteralNutritionVolumeRelevant', () {
    test('enteralNutrition true returns true', () {
      expect(
        isEnteralNutritionVolumeRelevant(
          const CalculatorRelevanceContext(enteralNutrition: true),
        ),
        true,
      );
    });

    test('enteralNutrition false (and everything else false) returns false', () {
      expect(
        isEnteralNutritionVolumeRelevant(const CalculatorRelevanceContext()),
        false,
      );
    });

    test(
      'parenteralNutrition true alone (enteralNutrition false) still '
      'returns false - not gated on the wrong flag',
      () {
        expect(
          isEnteralNutritionVolumeRelevant(
            const CalculatorRelevanceContext(parenteralNutrition: true),
          ),
          false,
        );
      },
    );
  });
}
