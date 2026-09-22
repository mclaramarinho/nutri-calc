import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/protein_needs_relevance.dart';

void main() {
  group('isProteinNeedsRelevant', () {
    test('always returns true regardless of context', () {
      expect(
        isProteinNeedsRelevant(const CalculatorRelevanceContext()),
        true,
      );
      expect(
        isProteinNeedsRelevant(
          const CalculatorRelevanceContext(age: 10, hospitalized: false),
        ),
        true,
      );
    });
  });
}
