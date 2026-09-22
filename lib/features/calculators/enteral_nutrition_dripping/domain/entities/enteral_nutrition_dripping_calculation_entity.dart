import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';

/// A persisted Enteral Nutrition Dripping calculation for a patient (the
/// `ENTERAL_NUTRITIONS_DRIPPING` table). Mirrors `NitrogenBalanceCalculationEntity`'s
/// shape - a single `value` plus the `inputParams` that produced it.
class EnteralNutritionDrippingCalculationEntity {
  final String? id;
  final String patientId;
  final double value;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const EnteralNutritionDrippingCalculationEntity({
    required this.patientId,
    required this.value,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
