import 'package:json_annotation/json_annotation.dart';
part "measurement_model.g.dart";

@JsonSerializable()
class MeasurementModel {
  final String? id;
  final double value;
  final DateTime createdAt;
  final String patientId;

  const MeasurementModel({
    required this.value,
    required this.createdAt,
    required this.patientId,
    this.id,
  });

  Map<String, dynamic> toJson() => _$MeasurementModelToJson(this);

  factory MeasurementModel.fromJson(Map<String, dynamic> json) =>
      _$MeasurementModelFromJson(json);
}
