import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/entities/nrs_2002_calculation_entity.dart';

part "nrs_2002_model.g.dart";

@JsonSerializable()
class Nrs2002Model {
  final String id;
  final String patientId;
  final int score;
  final DateTime createdAt;

  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) — encoded/decoded here at the model
  // layer, per the ADR's documented convention.
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const Nrs2002Model({
    required this.id,
    required this.patientId,
    required this.score,
    required this.createdAt,
    required this.inputParams,
  });

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  Map<String, dynamic> toJson() => _$Nrs2002ModelToJson(this);

  factory Nrs2002Model.fromJson(Map<String, dynamic> json) =>
      _$Nrs2002ModelFromJson(json);

  Nrs2002CalculationEntity toEntity() => Nrs2002CalculationEntity(
    id: id,
    patientId: patientId,
    score: score,
    createdAt: createdAt,
    inputParams: inputParams,
  );

  factory Nrs2002Model.fromEntity(
    Nrs2002CalculationEntity entity, {
    String? id,
  }) => Nrs2002Model(
    id: id ?? entity.id!,
    patientId: entity.patientId,
    score: entity.score,
    createdAt: entity.createdAt,
    inputParams: entity.inputParams,
  );
}
