import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';

/// A persisted Protein Needs calculation for a patient (the `PROTEIN_NEEDS`
/// table). Mirrors `EnergyExpenditureCalculationEntity`'s shape - a
/// `minValue`/`maxValue` range (the plain `ProteinNeeds` calculation result
/// is a range) instead of a single `value`.
class ProteinNeedsCalculationEntity {
  final String? id;
  final String patientId;
  final double minValue;
  final double maxValue;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const ProteinNeedsCalculationEntity({
    required this.patientId,
    required this.minValue,
    required this.maxValue,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
