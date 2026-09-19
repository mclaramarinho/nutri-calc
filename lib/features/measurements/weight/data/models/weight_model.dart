import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/measurements/data/models/measurement_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
part "weight_model.g.dart";

@JsonSerializable()
class WeightModel extends MeasurementModel {
  @JsonKey(toJson: _boolToInt, fromJson: _intToBool)
  final bool considerForCalculations;
  @JsonKey(toJson: _weightTypeToJson, fromJson: _weightTypeFromJson)
  final WeightTypeEnum weightType;

  const WeightModel({
    required super.value,
    required super.createdAt,
    required super.patientId,
    required this.considerForCalculations,
    required this.weightType,
    super.id,
  });

  static int _boolToInt(bool value) => value ? 1 : 0;
  static bool _intToBool(dynamic value) => value == 1 || value == true;

  static String _weightTypeToJson(WeightTypeEnum value) => value.name;
  static WeightTypeEnum _weightTypeFromJson(dynamic value) =>
      WeightTypeEnum.fromJson(value as String);

  @override
  Map<String, dynamic> toJson() => _$WeightModelToJson(this);

  factory WeightModel.fromJson(Map<String, dynamic> json) =>
      _$WeightModelFromJson(json);
}
