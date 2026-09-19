import 'package:nutri_calc/features/measurements/domain/entities/measurement_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';

class WeightEntity implements MeasurementEntity {
  @override
  final String? id;
  @override
  final double value;
  @override
  final DateTime createdAt;
  @override
  final String patientId;
  final bool considerForCalculations;
  final WeightTypeEnum weightType;

  const WeightEntity({
    required this.createdAt,
    required this.value,
    required this.patientId,
    required this.considerForCalculations,
    required this.weightType,
    this.id,
  });

  WeightEntity copyWith({
    String? id,
    double? value,
    DateTime? createdAt,
    String? patientId,
    bool? considerForCalculations,
    WeightTypeEnum? weightType,
  }) => WeightEntity(
    createdAt: createdAt ?? this.createdAt,
    value: value ?? this.value,
    patientId: patientId ?? this.patientId,
    id: id ?? this.id,
    considerForCalculations:
        considerForCalculations ?? this.considerForCalculations,
    weightType: weightType ?? this.weightType,
  );
}
