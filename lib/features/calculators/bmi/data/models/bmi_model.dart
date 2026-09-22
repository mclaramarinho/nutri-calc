import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

part "bmi_model.g.dart";

@JsonSerializable()
class BmiModel {
  final String id;
  final String patientId;
  final double value;

  @JsonKey(toJson: _classificationToJson, fromJson: _classificationFromJson)
  final BmiClassification classification;

  final DateTime createdAt;

  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) — encoded/decoded here at the model
  // layer, per the ADR's documented convention.
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const BmiModel({
    required this.id,
    required this.patientId,
    required this.value,
    required this.classification,
    required this.createdAt,
    required this.inputParams,
  });

  static String _classificationToJson(BmiClassification value) => value.name;
  static BmiClassification _classificationFromJson(dynamic value) =>
      BmiClassification.values.byName(value as String);

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  Map<String, dynamic> toJson() => _$BmiModelToJson(this);

  factory BmiModel.fromJson(Map<String, dynamic> json) =>
      _$BmiModelFromJson(json);

  BmiCalculationEntity toEntity() => BmiCalculationEntity(
    id: id,
    patientId: patientId,
    value: value,
    classification: classification,
    createdAt: createdAt,
    inputParams: inputParams,
  );

  factory BmiModel.fromEntity(BmiCalculationEntity entity, {String? id}) =>
      BmiModel(
        id: id ?? entity.id!,
        patientId: entity.patientId,
        value: entity.value,
        classification: entity.classification,
        createdAt: entity.createdAt,
        inputParams: entity.inputParams,
      );
}
