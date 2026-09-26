import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/estimated_weight/domain/estimated_weight_relevance.dart';

void main() {
  test('returns false when neither hospitalized nor confined to bed', () {
    expect(
      isEstimatedWeightRelevant(const CalculatorRelevanceContext()),
      isFalse,
    );
  });

  test('returns true when hospitalized', () {
    expect(
      isEstimatedWeightRelevant(
        const CalculatorRelevanceContext(hospitalized: true),
      ),
      isTrue,
    );
  });

  test('returns true when confined to bed', () {
    expect(
      isEstimatedWeightRelevant(
        const CalculatorRelevanceContext(confinedToBed: true),
      ),
      isTrue,
    );
  });

  test('returns true when both hospitalized and confined to bed', () {
    expect(
      isEstimatedWeightRelevant(
        const CalculatorRelevanceContext(
          hospitalized: true,
          confinedToBed: true,
        ),
      ),
      isTrue,
    );
  });
}
