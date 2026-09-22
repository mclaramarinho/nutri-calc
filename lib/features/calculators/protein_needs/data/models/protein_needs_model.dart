import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/entities/protein_needs_calculation_entity.dart';

part "protein_needs_model.g.dart";

@JsonSerializable()
class ProteinNeedsModel {
  final String id;
  final String patientId;
  final double minValue;
  final double maxValue;
  final DateTime createdAt;

  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) — encoded/decoded here at the model
  // layer, per the ADR's documented convention.
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const ProteinNeedsModel({
    required this.id,
    required this.patientId,
    required this.minValue,
    required this.maxValue,
    required this.createdAt,
    required this.inputParams,
  });

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  Map<String, dynamic> toJson() => _$ProteinNeedsModelToJson(this);

  factory ProteinNeedsModel.fromJson(Map<String, dynamic> json) =>
      _$ProteinNeedsModelFromJson(json);

  ProteinNeedsCalculationEntity toEntity() => ProteinNeedsCalculationEntity(
    id: id,
    patientId: patientId,
    minValue: minValue,
    maxValue: maxValue,
    createdAt: createdAt,
    inputParams: inputParams,
  );

  factory ProteinNeedsModel.fromEntity(
    ProteinNeedsCalculationEntity entity, {
    String? id,
  }) => ProteinNeedsModel(
    id: id ?? entity.id!,
    patientId: entity.patientId,
    minValue: entity.minValue,
    maxValue: entity.maxValue,
    createdAt: entity.createdAt,
    inputParams: entity.inputParams,
  );
}
