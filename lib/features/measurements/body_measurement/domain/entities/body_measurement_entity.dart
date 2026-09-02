import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_type_enum.dart';
import 'package:nutri_calc/features/measurements/domain/entities/measurement_entity.dart';

class BodyMeasurementEntity implements MeasurementEntity {
  @override
  final DateTime createdAt;
  @override
  final String? id;
  @override
  final String patientId;
  @override
  final double value;

  final BodyMeasurementTypeEnum measurementType;

  const BodyMeasurementEntity({
    required this.createdAt,
    required this.patientId,
    required this.value,
    required this.measurementType,
    this.id,
  });

  BodyMeasurementEntity copyWith({
    DateTime? createdAt,
    String? id,
    String? patientId,
    double? value,
    BodyMeasurementTypeEnum? measurementType,
  }) => BodyMeasurementEntity(
    createdAt: createdAt ?? this.createdAt,
    patientId: patientId ?? this.patientId,
    value: value ?? this.value,
    measurementType: measurementType ?? this.measurementType,
    id: id ?? this.id,
  );
}
