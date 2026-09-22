import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';

/// A persisted Glucose Infusion Rate (TIG) calculation for a patient (the
/// `GLUCOSE_INFUSION_RATES` table). Mirrors `NitrogenBalanceCalculationEntity`'s
/// shape - a single `value` plus the `inputParams` that produced it.
class GlucoseInfusionRateCalculationEntity {
  final String? id;
  final String patientId;
  final double value;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const GlucoseInfusionRateCalculationEntity({
    required this.patientId,
    required this.value,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
