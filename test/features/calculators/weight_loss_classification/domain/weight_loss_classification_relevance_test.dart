import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/weight_loss_classification_relevance.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';

WeightEntity _weight(double value, DateTime createdAt) => WeightEntity(
  createdAt: createdAt,
  value: value,
  patientId: 'patient-a',
  considerForCalculations: true,
  weightType: WeightTypeEnum.measuredByScale,
);

void main() {
  group('isWeightLossClassificationRelevant', () {
    test(
      '>= 2 weights, newest strictly lower than previous (decreasing): true',
      () {
        final context = CalculatorRelevanceContext(
          weights: [
            _weight(65, DateTime(2026, 9, 20)),
            _weight(70, DateTime(2026, 9, 1)),
          ],
        );

        expect(isWeightLossClassificationRelevant(context), isTrue);
      },
    );

    test('tie between the 2 most recent weights: false', () {
      final context = CalculatorRelevanceContext(
        weights: [
          _weight(70, DateTime(2026, 9, 20)),
          _weight(70, DateTime(2026, 9, 1)),
        ],
      );

      expect(isWeightLossClassificationRelevant(context), isFalse);
    });

    test('increase between the 2 most recent weights: false', () {
      final context = CalculatorRelevanceContext(
        weights: [
          _weight(75, DateTime(2026, 9, 20)),
          _weight(70, DateTime(2026, 9, 1)),
        ],
      );

      expect(isWeightLossClassificationRelevant(context), isFalse);
    });

    test(
      '3+ weights: only the top-2 (newest) are considered, older entries '
      'are ignored even if they would change the outcome',
      () {
        // Top-2 (index 0 vs 1) show an increase (75 > 70), so this must be
        // false, even though a 3rd/older weight (60) would make the overall
        // trend look like a loss if it were (wrongly) taken into account.
        final increasingTop2 = CalculatorRelevanceContext(
          weights: [
            _weight(75, DateTime(2026, 9, 20)),
            _weight(70, DateTime(2026, 9, 10)),
            _weight(60, DateTime(2026, 9, 1)),
          ],
        );
        expect(isWeightLossClassificationRelevant(increasingTop2), isFalse);

        // Top-2 show a decrease (65 < 70), so this must be true, regardless
        // of what a 3rd/older weight (60, which is lower than the current
        // weight too) would otherwise suggest.
        final decreasingTop2 = CalculatorRelevanceContext(
          weights: [
            _weight(65, DateTime(2026, 9, 20)),
            _weight(70, DateTime(2026, 9, 10)),
            _weight(60, DateTime(2026, 9, 1)),
          ],
        );
        expect(isWeightLossClassificationRelevant(decreasingTop2), isTrue);
      },
    );

    test('fewer than 2 weights: false', () {
      expect(
        isWeightLossClassificationRelevant(const CalculatorRelevanceContext()),
        isFalse,
      );
      expect(
        isWeightLossClassificationRelevant(
          CalculatorRelevanceContext(
            weights: [_weight(70, DateTime(2026, 9, 20))],
          ),
        ),
        isFalse,
      );
    });
  });
}
