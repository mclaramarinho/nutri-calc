import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/measurements/data/models/measurement_model.dart';
part "height_model.g.dart";

@JsonSerializable()
class HeightModel extends MeasurementModel {
  const HeightModel({
    required super.value,
    required super.createdAt,
    required super.patientId,
    super.id,
  });

  @override
  Map<String, dynamic> toJson() => _$HeightModelToJson(this);

  factory HeightModel.fromJson(Map<String, dynamic> json) =>
      _$HeightModelFromJson(json);
}
