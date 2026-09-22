import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_params_json_codec.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/entities/weight_loss_classification_calculation_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';

part "weight_loss_classification_model.g.dart";

@JsonSerializable()
class WeightLossClassificationModel {
  final String id;
  final String patientId;
  final double percentage;
  final int timeReference;

  @JsonKey(toJson: _classificationToJson, fromJson: _classificationFromJson)
  final WeightLossClassification classification;

  final DateTime createdAt;

  // `inputParams` is stored as a JSON-encoded TEXT column
  // (`TableSqlTypes.json`, ADR 0005) — encoded/decoded here at the model
  // layer, per the ADR's documented convention.
  @JsonKey(toJson: _paramsToJson, fromJson: _paramsFromJson)
  final List<InputParamEntity> inputParams;

  const WeightLossClassificationModel({
    required this.id,
    required this.patientId,
    required this.percentage,
    required this.timeReference,
    required this.classification,
    required this.createdAt,
    required this.inputParams,
  });

  static String _classificationToJson(WeightLossClassification value) =>
      value.name;
  static WeightLossClassification _classificationFromJson(dynamic value) =>
      WeightLossClassification.values.byName(value as String);

  static String _paramsToJson(List<InputParamEntity> value) =>
      InputParamsJsonCodec.toJson(value);

  static List<InputParamEntity> _paramsFromJson(dynamic value) =>
      InputParamsJsonCodec.fromJson(value);

  Map<String, dynamic> toJson() => _$WeightLossClassificationModelToJson(this);

  factory WeightLossClassificationModel.fromJson(Map<String, dynamic> json) =>
      _$WeightLossClassificationModelFromJson(json);

  WeightLossClassificationCalculationEntity toEntity() =>
      WeightLossClassificationCalculationEntity(
        id: id,
        patientId: patientId,
        percentage: percentage,
        timeReference: timeReference,
        classification: classification,
        createdAt: createdAt,
        inputParams: inputParams,
      );

  factory WeightLossClassificationModel.fromEntity(
    WeightLossClassificationCalculationEntity entity, {
    String? id,
  }) => WeightLossClassificationModel(
    id: id ?? entity.id!,
    patientId: entity.patientId,
    percentage: entity.percentage,
    timeReference: entity.timeReference,
    classification: entity.classification,
    createdAt: entity.createdAt,
    inputParams: entity.inputParams,
  );
}
