import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/entities/strong_kids_calculation_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_score_classification.enum.dart';

part "strong_kids_model.g.dart";

@JsonSerializable()
class StrongKidsModel {
  final String id;
  final String patientId;
  final int score;

  @JsonKey(toJson: _classificationToJson, fromJson: _classificationFromJson)
  final StrongKidsScoreClassification classification;

  final DateTime createdAt;

  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) — encoded/decoded here at the model
  // layer, per the ADR's documented convention.
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const StrongKidsModel({
    required this.id,
    required this.patientId,
    required this.score,
    required this.classification,
    required this.createdAt,
    required this.inputParams,
  });

  static String _classificationToJson(StrongKidsScoreClassification value) =>
      value.name;
  static StrongKidsScoreClassification _classificationFromJson(
    dynamic value,
  ) => StrongKidsScoreClassification.values.byName(value as String);

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  Map<String, dynamic> toJson() => _$StrongKidsModelToJson(this);

  factory StrongKidsModel.fromJson(Map<String, dynamic> json) =>
      _$StrongKidsModelFromJson(json);

  StrongKidsCalculationEntity toEntity() => StrongKidsCalculationEntity(
    id: id,
    patientId: patientId,
    score: score,
    classification: classification,
    createdAt: createdAt,
    inputParams: inputParams,
  );

  factory StrongKidsModel.fromEntity(
    StrongKidsCalculationEntity entity, {
    String? id,
  }) => StrongKidsModel(
    id: id ?? entity.id!,
    patientId: entity.patientId,
    score: entity.score,
    classification: entity.classification,
    createdAt: entity.createdAt,
    inputParams: entity.inputParams,
  );
}
