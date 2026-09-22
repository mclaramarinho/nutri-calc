import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';

/// A persisted Energy Expenditure calculation for a patient (the
/// `ENERGY_EXPENDITURES` table). Mirrors `BmiCalculationEntity`'s shape but
/// stores a `minValue`/`maxValue` range (the plain `EER`/`EERPocket`
/// calculation results are ranges, not single values) instead of a single
/// `value`.
class EnergyExpenditureCalculationEntity {
  final String? id;
  final String patientId;
  final EnergyExpenditureFormulaEnum formula;
  final double minValue;
  final double maxValue;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const EnergyExpenditureCalculationEntity({
    required this.patientId,
    required this.formula,
    required this.minValue,
    required this.maxValue,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
