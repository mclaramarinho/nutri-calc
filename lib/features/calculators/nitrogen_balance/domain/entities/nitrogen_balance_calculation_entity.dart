import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';

/// A persisted Nitrogen Balance calculation for a patient (the
/// `NITROGEN_BALANCES` table). Mirrors `BmiCalculationEntity`'s shape - a
/// single `value` plus the `inputParams` that produced it.
class NitrogenBalanceCalculationEntity {
  final String? id;
  final String patientId;
  final double value;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const NitrogenBalanceCalculationEntity({
    required this.patientId,
    required this.value,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
