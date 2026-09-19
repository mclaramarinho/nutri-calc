import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

/// A persisted BMI calculation for a patient (the `BMI` table). Named
/// distinctly from `Bmi` (`lib/shared/services/calculator/domain/entities/bmi/bmi.entity.dart`,
/// the plain calculation-result value object returned by `CalculateBmi`) to
/// avoid clashing with it — this entity additionally carries persistence
/// concerns (`id`, `patientId`, `createdAt`, `inputParams`).
class BmiCalculationEntity {
  final String? id;
  final String patientId;
  final double value;
  final BmiClassification classification;
  final DateTime createdAt;
  final List<InputParamEntity> inputParams;

  const BmiCalculationEntity({
    required this.patientId,
    required this.value,
    required this.classification,
    required this.createdAt,
    required this.inputParams,
    this.id,
  });
}
