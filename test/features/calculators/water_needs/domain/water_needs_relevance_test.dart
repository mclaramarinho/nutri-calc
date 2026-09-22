import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/water_needs_relevance.dart';

void main() {
  group('isWaterNeedsRelevant', () {
    test('always returns true regardless of context (open PO judgment call)', () {
      expect(isWaterNeedsRelevant(const CalculatorRelevanceContext()), true);
      expect(
        isWaterNeedsRelevant(
          const CalculatorRelevanceContext(age: 10, hospitalized: false),
        ),
        true,
      );
    });
  });
}
