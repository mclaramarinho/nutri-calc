import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

/// Roadmap 3.1 Calculator Relevance table row for Adjusted Obesity: relevant
/// only when the patient's current BMI classification is `low`, `obesity`,
/// `obesityGrade2`, or `obesityGrade3` - explicitly not `overweight`/
/// `eutrophy`. If BMI is unknown/uncomputed (no weight+height yet), this
/// returns `false` (insufficient data != relevant).
///
/// Identical BMI gating to Adequation's - the two calculators are clinically
/// paired, both driven off "is this patient over/underweight" (Slice 10 po
/// decision, 2026-09-26). Kept as its own function rather than shared, same
/// near-identical-one-liner precedent as `enteral_nutrition_dripping`/
/// `enteral_nutrition_speed`.
bool isAdjustedObesityRelevant(CalculatorRelevanceContext context) {
  final classification = context.bmi?.classification;
  if (classification == null) return false;

  return classification == BmiClassification.low ||
      classification == BmiClassification.obesity ||
      classification == BmiClassification.obesityGrade2 ||
      classification == BmiClassification.obesityGrade3;
}
