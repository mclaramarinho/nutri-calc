import 'package:nutri_calc/features/measurements/domain/entities/measurement_entity.dart';

class WeightEntity implements MeasurementEntity {
  @override
  final String? id;
  @override
  final double value;
  @override
  final DateTime createdAt;
  @override
  final String patientId;

  const WeightEntity({
    required this.createdAt,
    required this.value,
    required this.patientId,
    this.id,
  });

  WeightEntity copyWith({
    String? id,
    double? value,
    DateTime? createdAt,
    String? patientId,
  }) => WeightEntity(
    createdAt: createdAt ?? this.createdAt,
    value: value ?? this.value,
    patientId: patientId ?? this.patientId,
    id: id ?? this.id,
  );
}
