import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/adjusted_obesity/domain/adjusted_obesity_relevance.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

void main() {
  test('returns false when BMI is unknown/uncomputed', () {
    expect(
      isAdjustedObesityRelevant(const CalculatorRelevanceContext()),
      isFalse,
    );
  });

  for (final classification in [
    BmiClassification.low,
    BmiClassification.obesity,
    BmiClassification.obesityGrade2,
    BmiClassification.obesityGrade3,
  ]) {
    test('returns true for BmiClassification.$classification', () {
      final context = CalculatorRelevanceContext(
        bmi: Bmi(value: 20, classification: classification),
      );
      expect(isAdjustedObesityRelevant(context), isTrue);
    });
  }

  for (final classification in [
    BmiClassification.eutrophy,
    BmiClassification.overweight,
  ]) {
    test('returns false for BmiClassification.$classification', () {
      final context = CalculatorRelevanceContext(
        bmi: Bmi(value: 24, classification: classification),
      );
      expect(isAdjustedObesityRelevant(context), isFalse);
    });
  }
}
