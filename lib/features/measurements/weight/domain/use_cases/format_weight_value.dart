import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_adequation_classification.enum.dart';

/// Formats a `WeightEntity`'s persisted value for display, per weight type
/// (product decisions, po pass 2026-09-26): Adequation's `value` is a
/// percentage rendered with its recomputed classification; Adjusted Dry
/// Weight's `value` is a midpoint, rendered as the min/max range read back
/// out of `inputParams`; every other type is a plain kg value.
///
/// Extracted from `patient_measurements_tab.dart`'s private
/// `_formatWeightValue` (ADR 0009) so both the Weights tab and
/// `GetWeightHistoryUseCase` share one formatting implementation instead of
/// two independently-maintained copies.
class FormatWeightValue {
  const FormatWeightValue();

  String _classificationLabel(WeightAdequationClassification classification) {
    switch (classification) {
      case .severeMalnutrition:
        return "Desnutrição grave";
      case .moderateMalnutrition:
        return "Desnutrição moderada";
      case .mildMalnutrition:
        return "Desnutrição leve";
      case .eutrophy:
        return "Eutrofia";
      case .overweight:
        return "Sobrepeso";
      case .obesity:
        return "Obesidade";
    }
  }

  String call(WeightEntity weight) {
    if (weight.weightType == WeightTypeEnum.adequation) {
      final classification = WeightAdequationClassification.getByValue(
        weight.value,
      );
      return '${weight.value.toStringAsFixed(2)}% (${_classificationLabel(classification)})';
    }

    if (weight.weightType == WeightTypeEnum.adjustedDryWeight) {
      final min = weight.inputParams
          .firstWhere((p) => p.key == "dry_weight_min_kg")
          .value;
      final max = weight.inputParams
          .firstWhere((p) => p.key == "dry_weight_max_kg")
          .value;
      return '$min – $max kg';
    }

    return '${weight.value} kg';
  }
}
