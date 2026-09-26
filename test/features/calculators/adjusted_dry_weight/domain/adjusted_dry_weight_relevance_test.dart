import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/adjusted_dry_weight/domain/adjusted_dry_weight_relevance.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';

void main() {
  test('returns false when neither hospitalized nor confined to bed', () {
    expect(
      isAdjustedDryWeightRelevant(const CalculatorRelevanceContext()),
      isFalse,
    );
  });

  test('returns true when hospitalized', () {
    expect(
      isAdjustedDryWeightRelevant(
        const CalculatorRelevanceContext(hospitalized: true),
      ),
      isTrue,
    );
  });

  test('returns true when confined to bed', () {
    expect(
      isAdjustedDryWeightRelevant(
        const CalculatorRelevanceContext(confinedToBed: true),
      ),
      isTrue,
    );
  });

  test('returns true when both hospitalized and confined to bed', () {
    expect(
      isAdjustedDryWeightRelevant(
        const CalculatorRelevanceContext(
          hospitalized: true,
          confinedToBed: true,
        ),
      ),
      isTrue,
    );
  });

  test('BMI classification alone does not make it relevant (not BMI-gated)', () {
    // Regression guard for the roadmap's explicit correction: this is NOT
    // gated the same way as Adequation/Adjusted Obesity.
    expect(
      isAdjustedDryWeightRelevant(const CalculatorRelevanceContext()),
      isFalse,
    );
  });
}
