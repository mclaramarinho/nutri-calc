import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

/// Roadmap 3.1 Calculator Relevance table row for Ideal Weight: relevant
/// only when the patient's current BMI classification is `low`, `obesity`,
/// `obesityGrade2`, or `obesityGrade3` - explicitly not `overweight`/
/// `eutrophy`. If BMI is unknown/uncomputed (no weight+height yet), this
/// returns `false` (insufficient data != relevant).
bool isIdealWeightRelevant(CalculatorRelevanceContext context) {
  final classification = context.bmi?.classification;
  if (classification == null) return false;

  return classification == BmiClassification.low ||
      classification == BmiClassification.obesity ||
      classification == BmiClassification.obesityGrade2 ||
      classification == BmiClassification.obesityGrade3;
}
