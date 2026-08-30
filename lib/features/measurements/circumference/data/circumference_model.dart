import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/measurements/data/models/measurement_model.dart';

part 'circumference_model.g.dart';

@JsonSerializable()
class CircumferenceModel extends MeasurementModel {
  final String measurementType;

  const CircumferenceModel({
    required this.measurementType,
    required super.createdAt,
    required super.patientId,
    required super.value,
    super.id,
  });

  @override
  Map<String, dynamic> toJson() => _$CircumferenceModelToJson(this);

  factory CircumferenceModel.fromJson(Map<String, dynamic> json) =>
      _$CircumferenceModelFromJson(json);
}
