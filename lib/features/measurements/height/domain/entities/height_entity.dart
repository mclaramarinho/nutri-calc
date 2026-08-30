import 'package:nutri_calc/features/measurements/domain/entities/measurement_entity.dart';

class HeightEntity implements MeasurementEntity {
  @override
  final String? id;
  @override
  final double value;
  @override
  final DateTime createdAt;
  @override
  final String patientId;

  const HeightEntity({
    required this.createdAt,
    required this.value,
    required this.patientId,
    this.id,
  });

  HeightEntity copyWith({
    String? id,
    double? value,
    DateTime? createdAt,
    String? patientId,
  }) => HeightEntity(
    createdAt: createdAt ?? this.createdAt,
    value: value ?? this.value,
    patientId: patientId ?? this.patientId,
    id: id ?? this.id,
  );
}
