class WeightEntity {
  final String? id;
  final double value;
  final DateTime createdAt;
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
