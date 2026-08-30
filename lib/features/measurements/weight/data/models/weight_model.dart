import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/measurements/data/models/measurement_model.dart';
part "weight_model.g.dart";

@JsonSerializable()
class WeightModel extends MeasurementModel {
  const WeightModel({
    required super.value,
    required super.createdAt,
    required super.patientId,
    super.id,
  });

  @override
  Map<String, dynamic> toJson() => _$WeightModelToJson(this);

  factory WeightModel.fromJson(Map<String, dynamic> json) =>
      _$WeightModelFromJson(json);
}
