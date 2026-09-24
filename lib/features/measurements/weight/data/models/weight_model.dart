import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/features/measurements/data/models/measurement_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
part "weight_model.g.dart";

@JsonSerializable()
class WeightModel extends MeasurementModel {
  @JsonKey(toJson: _boolToInt, fromJson: _intToBool)
  final bool considerForCalculations;
  @JsonKey(toJson: _weightTypeToJson, fromJson: _weightTypeFromJson)
  final WeightTypeEnum weightType;
  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) - encoded/decoded here at the model
  // layer, per the ADR's documented convention (Slice 8, ADR 0007).
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const WeightModel({
    required super.value,
    required super.createdAt,
    required super.patientId,
    required this.considerForCalculations,
    required this.weightType,
    this.inputParams = const [],
    super.id,
  });

  static int _boolToInt(bool value) => value ? 1 : 0;
  static bool _intToBool(dynamic value) => value == 1 || value == true;

  static String _weightTypeToJson(WeightTypeEnum value) => value.name;
  static WeightTypeEnum _weightTypeFromJson(dynamic value) =>
      WeightTypeEnum.fromJson(value as String);

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  @override
  Map<String, dynamic> toJson() => _$WeightModelToJson(this);

  factory WeightModel.fromJson(Map<String, dynamic> json) =>
      _$WeightModelFromJson(json);
}
