import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/measurements/data/models/measurement_model.dart';

part 'body_measurement_model.g.dart';

@JsonSerializable()
class BodyMeasurementModel extends MeasurementModel {
  final String measurementType;

  const BodyMeasurementModel({
    required this.measurementType,
    required super.createdAt,
    required super.patientId,
    required super.value,
    super.id,
  });

  @override
  Map<String, dynamic> toJson() => _$BodyMeasurementModelToJson(this);

  factory BodyMeasurementModel.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementModelFromJson(json);
}
