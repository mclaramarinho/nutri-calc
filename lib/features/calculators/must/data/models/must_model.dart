import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/features/calculators/must/domain/entities/must_calculation_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_classification_result.enum.dart';

part "must_model.g.dart";

@JsonSerializable()
class MustModel {
  final String id;
  final String patientId;
  final int score;
  final int scoreStep1;
  final int scoreStep2;
  final int scoreStep3;

  @JsonKey(toJson: _classificationToJson, fromJson: _classificationFromJson)
  final MustClassificationResult classification;

  final DateTime createdAt;

  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) — encoded/decoded here at the model
  // layer, per the ADR's documented convention.
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const MustModel({
    required this.id,
    required this.patientId,
    required this.score,
    required this.scoreStep1,
    required this.scoreStep2,
    required this.scoreStep3,
    required this.classification,
    required this.createdAt,
    required this.inputParams,
  });

  static String _classificationToJson(MustClassificationResult value) =>
      value.name;
  static MustClassificationResult _classificationFromJson(dynamic value) =>
      MustClassificationResult.values.byName(value as String);

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  Map<String, dynamic> toJson() => _$MustModelToJson(this);

  factory MustModel.fromJson(Map<String, dynamic> json) =>
      _$MustModelFromJson(json);

  MustCalculationEntity toEntity() => MustCalculationEntity(
    id: id,
    patientId: patientId,
    score: score,
    scoreStep1: scoreStep1,
    scoreStep2: scoreStep2,
    scoreStep3: scoreStep3,
    classification: classification,
    createdAt: createdAt,
    inputParams: inputParams,
  );

  factory MustModel.fromEntity(MustCalculationEntity entity, {String? id}) =>
      MustModel(
        id: id ?? entity.id!,
        patientId: entity.patientId,
        score: entity.score,
        scoreStep1: entity.scoreStep1,
        scoreStep2: entity.scoreStep2,
        scoreStep3: entity.scoreStep3,
        classification: entity.classification,
        createdAt: entity.createdAt,
        inputParams: entity.inputParams,
      );
}
