abstract class MeasurementEntity {
  final String? id;
  final double value;
  final DateTime createdAt;
  final String patientId;

  const MeasurementEntity({
    required this.createdAt,
    required this.value,
    required this.patientId,
    this.id,
  });
}
